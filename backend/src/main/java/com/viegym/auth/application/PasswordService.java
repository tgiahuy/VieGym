package com.viegym.auth.application;

import com.viegym.auth.api.ChangePasswordRequest;
import com.viegym.auth.api.ForgotPasswordRequest;
import com.viegym.auth.api.RegisterChallengeResponse;
import com.viegym.auth.api.ResetPasswordRequest;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.AccountStatus;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.OtpPurpose;
import com.viegym.identity.PasswordResetProof;
import com.viegym.identity.PasswordResetProofRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import com.viegym.token.RefreshTokenService;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.Locale;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PasswordService {

    private final UserRepository users;
    private final PasswordResetProofRepository proofs;
    private final OtpIssueHelper otpIssuer;
    private final PasswordPolicy passwordPolicy;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenService refreshTokens;
    private final Clock clock;

    public PasswordService(
            UserRepository users,
            PasswordResetProofRepository proofs,
            OtpIssueHelper otpIssuer,
            PasswordPolicy passwordPolicy,
            PasswordEncoder passwordEncoder,
            RefreshTokenService refreshTokens,
            Clock clock) {
        this.users = users;
        this.proofs = proofs;
        this.otpIssuer = otpIssuer;
        this.passwordPolicy = passwordPolicy;
        this.passwordEncoder = passwordEncoder;
        this.refreshTokens = refreshTokens;
        this.clock = clock;
    }

    @Transactional
    public RegisterChallengeResponse forgot(ForgotPasswordRequest request) {
        String email =
                request == null || request.email() == null
                        ? null
                        : request.email().trim().toLowerCase(Locale.ROOT);
        if (email == null || email.isBlank()) {
            return syntheticChallenge(email);
        }
        User user = users.findByEmail(email).orElse(null);
        if (user == null
                || user.authProvider() != AuthProvider.LOCAL
                || user.status() != AccountStatus.ACTIVE) {
            return syntheticChallenge(email);
        }
        return otpIssuer.createAndSend(user, OtpPurpose.PASSWORD_RESET, OffsetDateTime.now(clock));
    }

    private RegisterChallengeResponse syntheticChallenge(String email) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        return new RegisterChallengeResponse(
                "otp_" + UUID.randomUUID(),
                mask(email),
                OtpPurpose.PASSWORD_RESET,
                now.plusMinutes(10),
                now.plusMinutes(1));
    }

    private static String mask(String email) {
        if (email == null) {
            return "***";
        }
        int at = email.indexOf('@');
        return at <= 0 ? "***" : email.charAt(0) + "***" + email.substring(at);
    }

    @Transactional
    public void reset(ResetPasswordRequest request) {
        String proof = request == null ? null : request.resetProof();
        passwordPolicy.validate(request == null ? null : request.newPassword(), "newPassword");
        if (proof == null || proof.isBlank()) {
            throw invalidProof();
        }
        OffsetDateTime now = OffsetDateTime.now(clock);
        PasswordResetProof stored =
                proofs.findByProofHashForUpdate(OtpIssueHelper.sha256Hex(proof))
                        .orElseThrow(this::invalidProof);
        if (stored.consumedAt() != null || !now.isBefore(stored.expiresAt())) {
            throw invalidProof();
        }
        stored.consume(now);
        stored.user().changePassword(passwordEncoder.encode(request.newPassword()), now);
        refreshTokens.revokeAll(stored.user(), now);
    }

    @Transactional
    public void change(Long userId, ChangePasswordRequest request) {
        User user =
                users.findById(userId)
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.UNAUTHENTICATED, "User not found"));
        if (user.authProvider() != AuthProvider.LOCAL) {
            throw new ApiException(
                    ApiErrorCode.PASSWORD_CHANGE_NOT_SUPPORTED,
                    "Password change is not supported for this account");
        }
        if (request == null
                || request.currentPassword() == null
                || !passwordEncoder.matches(request.currentPassword(), user.passwordHash())) {
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid credentials");
        }
        passwordPolicy.validate(request.newPassword(), "newPassword");
        OffsetDateTime now = OffsetDateTime.now(clock);
        user.changePassword(passwordEncoder.encode(request.newPassword()), now);
        refreshTokens.revokeAll(user, now);
    }

    private ApiException invalidProof() {
        return new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid reset proof");
    }
}
