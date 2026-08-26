package com.viegym.auth.application;

import com.viegym.auth.api.RegisterChallengeResponse;
import com.viegym.identity.OtpCode;
import com.viegym.identity.OtpCodeRepository;
import com.viegym.identity.OtpPurpose;
import com.viegym.identity.SecurityRateLimitEvent;
import com.viegym.identity.SecurityRateLimitEventRepository;
import com.viegym.identity.User;
import com.viegym.otp.OtpSender;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Package-private helper that generates a one-time code, persists a hashed record, dispatches it
 * via the configured {@link OtpSender}, and records a {@code OTP_SEND} rate-limit event.
 *
 * <p>Centralising this logic avoids duplication between the initial OTP issuance ({@link
 * OtpChallengeIssuer}) and subsequent resends ({@link OtpResendService}).
 */
@Component
class OtpIssueHelper {

    private static final int CODE_DIGITS = 6;
    private static final int CODE_MODULUS = 1_000_000; // 10^CODE_DIGITS
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final OtpCodeRepository otpCodes;
    private final SecurityRateLimitEventRepository rateLimitEvents;
    private final PasswordEncoder passwordEncoder;
    private final OtpSender otpSender;
    private final Clock clock;
    private final Duration otpTtl;
    private final Duration resendCooldown;
    private final short maxAttempts;

    OtpIssueHelper(
            OtpCodeRepository otpCodes,
            SecurityRateLimitEventRepository rateLimitEvents,
            PasswordEncoder passwordEncoder,
            OtpSender otpSender,
            Clock clock,
            @Value("${OTP_TTL:PT10M}") Duration otpTtl,
            @Value("${OTP_RESEND_COOLDOWN:PT1M}") Duration resendCooldown,
            @Value("${OTP_MAX_ATTEMPTS:5}") int maxAttempts) {
        this.otpCodes = otpCodes;
        this.rateLimitEvents = rateLimitEvents;
        this.passwordEncoder = passwordEncoder;
        this.otpSender = otpSender;
        this.clock = clock;
        this.otpTtl = otpTtl;
        this.resendCooldown = resendCooldown;
        this.maxAttempts = (short) maxAttempts;
    }

    /**
     * Creates a new OTP for {@code user} and {@code purpose}, persists it, delivers it, records an
     * {@code OTP_SEND} rate-limit event, and returns the challenge metadata.
     *
     * @param user the user who will receive the OTP
     * @param purpose the OTP purpose (e.g. REGISTER, PASSWORD_RESET)
     * @param now current timestamp from the call site's clock snapshot
     * @return an opaque {@link RegisterChallengeResponse} with the new challenge ID
     */
    RegisterChallengeResponse createAndSend(User user, OtpPurpose purpose, OffsetDateTime now) {
        String plainCode = generateCode();
        String codeHash = passwordEncoder.encode(plainCode);

        OtpCode otp =
                otpCodes.save(
                        new OtpCode(
                                user,
                                user.email(),
                                purpose,
                                codeHash,
                                maxAttempts,
                                now.plus(otpTtl),
                                now.plus(resendCooldown),
                                now));

        otpSender.send(user.email(), purpose, plainCode);

        rateLimitEvents.save(
                new SecurityRateLimitEvent(
                        SecurityRateLimitEvent.SCOPE_OTP_SEND, sha256Hex(user.email()), true, now));

        return new RegisterChallengeResponse(
                "otp_" + otp.id(),
                mask(user.email()),
                purpose,
                otp.expiresAt(),
                otp.resendAvailableAt());
    }

    private static String generateCode() {
        return String.format("%0" + CODE_DIGITS + "d", SECURE_RANDOM.nextInt(CODE_MODULUS));
    }

    private static String mask(String email) {
        int at = email.indexOf('@');
        if (at <= 0) {
            return "***";
        }
        return email.charAt(0) + "***" + email.substring(at);
    }

    /**
     * SHA-256 hex digest of {@code input}. Package-accessible for use in tests and sibling classes.
     */
    static String sha256Hex(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }
}
