package com.viegym.auth.application;

import com.viegym.auth.api.OtpVerifyRequest;
import com.viegym.auth.api.SessionResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.OtpCode;
import com.viegym.identity.OtpCodeRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.OffsetDateTime;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Atomically verifies an OTP challenge, activates the user account, and issues a session.
 *
 * <h3>Atomicity contract</h3>
 *
 * <ul>
 *   <li>Attempt count is <em>always</em> incremented, even on a wrong code, so that brute-force
 *       protection works correctly. This is achieved via {@code noRollbackFor =
 *       ApiException.class}: the transaction commits (persisting the incremented count) even when a
 *       business-rule exception is thrown.
 *   <li>OTP consumption, account activation and refresh-token creation occur in the same commit on
 *       success, guaranteeing that no partial state is observable.
 * </ul>
 */
@Service
public class OtpVerificationService {

    private static final String OTP_PREFIX = "otp_";

    private final OtpCodeRepository otpCodes;
    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final SessionIssuer sessionIssuer;
    private final PasswordResetProofService resetProofService;
    private final Clock clock;

    public OtpVerificationService(
            OtpCodeRepository otpCodes,
            UserRepository users,
            PasswordEncoder passwordEncoder,
            SessionIssuer sessionIssuer,
            PasswordResetProofService resetProofService,
            Clock clock) {
        this.otpCodes = otpCodes;
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.sessionIssuer = sessionIssuer;
        this.resetProofService = resetProofService;
        this.clock = clock;
    }

    /**
     * Verifies {@code request.code()} against the OTP identified by {@code request.challengeId()}.
     *
     * <p>On success: consumes the OTP, activates the user account, and returns a fresh session. On
     * failure: commits the incremented attempt count and throws the appropriate {@link
     * ApiException}.
     */
    @Transactional(noRollbackFor = ApiException.class)
    public SessionResponse verify(OtpVerifyRequest request) {
        Long otpId = parseChallengeId(request.challengeId());
        OffsetDateTime now = OffsetDateTime.now(clock);

        // Lock the row to serialise concurrent verification attempts.
        OtpCode otp =
                otpCodes.findByIdForUpdate(otpId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.OTP_INVALID,
                                                "OTP not found or invalid"));

        // Guard: terminal states checked BEFORE incrementing attempts.
        if (otp.consumedAt() != null) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "OTP has already been used");
        }
        if (now.isAfter(otp.expiresAt())) {
            throw new ApiException(ApiErrorCode.OTP_EXPIRED, "OTP has expired");
        }
        if (otp.attemptCount() >= otp.maxAttempts()) {
            throw new ApiException(
                    ApiErrorCode.OTP_ATTEMPTS_EXCEEDED, "OTP attempt limit exceeded");
        }
        if (request.purpose() != null && request.purpose() != otp.purpose()) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "OTP purpose does not match");
        }

        // Always increment so the count is committed even when the code is wrong.
        otp.incrementAttemptCount();

        if (!passwordEncoder.matches(request.code(), otp.codeHash())) {
            if (otp.attemptCount() >= otp.maxAttempts()) {
                throw new ApiException(
                        ApiErrorCode.OTP_ATTEMPTS_EXCEEDED, "OTP attempt limit exceeded");
            }
            throw new ApiException(ApiErrorCode.OTP_INVALID, "Invalid OTP code");
        }

        // Code is correct — consume OTP and perform the purpose-specific transition.
        otp.consume(now);

        Long userId = otp.user().id();
        User user =
                users.findById(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.RESOURCE_NOT_FOUND, "User not found"));
        if (otp.purpose() == com.viegym.identity.OtpPurpose.PASSWORD_RESET) {
            return SessionResponse.resetProof(resetProofService.issue(user));
        }
        user.activate(now);
        return sessionIssuer.issue(user, null);
    }

    private static Long parseChallengeId(String challengeId) {
        if (challengeId == null || !challengeId.startsWith(OTP_PREFIX)) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "Invalid challenge ID");
        }
        try {
            return Long.parseLong(challengeId.substring(OTP_PREFIX.length()));
        } catch (NumberFormatException e) {
            throw new ApiException(ApiErrorCode.OTP_INVALID, "Invalid challenge ID");
        }
    }
}
