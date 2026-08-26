package com.viegym.auth.application;

import com.viegym.auth.api.LoginRequest;
import com.viegym.auth.api.SessionResponse;
import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.identity.AccountStatus;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.SecurityRateLimitEvent;
import com.viegym.identity.SecurityRateLimitEventRepository;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Locale;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class LoginService {

    private final UserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final SessionIssuer sessionIssuer;
    private final SecurityRateLimitEventRepository rateLimitEvents;
    private final Clock clock;

    public LoginService(
            UserRepository users,
            PasswordEncoder passwordEncoder,
            SessionIssuer sessionIssuer,
            SecurityRateLimitEventRepository rateLimitEvents,
            Clock clock) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.sessionIssuer = sessionIssuer;
        this.rateLimitEvents = rateLimitEvents;
        this.clock = clock;
    }

    @Transactional
    public SessionResponse login(LoginRequest request) {
        String email = normalizeEmail(request == null ? null : request.email());
        String password = request == null ? null : request.password();
        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            throw new ApiValidationException(
                    List.of(
                            new FieldViolation(
                                    "credentials", "REQUIRED", "Credentials are required")));
        }

        OffsetDateTime now = OffsetDateTime.now(clock);
        User user = users.findByEmail(email).orElse(null);
        boolean valid =
                user != null
                        && user.authProvider() == AuthProvider.LOCAL
                        && passwordEncoder.matches(password, user.passwordHash());
        rateLimitEvents.save(
                new SecurityRateLimitEvent(
                        SecurityRateLimitEvent.SCOPE_LOGIN,
                        OtpIssueHelper.sha256Hex(email),
                        valid,
                        now));
        if (!valid) {
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid credentials");
        }

        ensureActive(user.status());
        user.recordLogin(now);
        return sessionIssuer.issue(user, request.deviceInfo());
    }

    static void ensureActive(AccountStatus status) {
        switch (status) {
            case ACTIVE -> {}
            case PENDING ->
                    throw new ApiException(ApiErrorCode.ACCOUNT_PENDING, "Account is pending");
            case LOCKED -> throw new ApiException(ApiErrorCode.ACCOUNT_LOCKED, "Account is locked");
            case DISABLED ->
                    throw new ApiException(ApiErrorCode.ACCOUNT_DISABLED, "Account is disabled");
        }
    }

    private static String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }
}
