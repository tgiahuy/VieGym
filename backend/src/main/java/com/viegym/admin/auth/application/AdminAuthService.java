package com.viegym.admin.auth.application;

import com.viegym.admin.audit.application.AdminAuditService;
import com.viegym.admin.auth.api.AdminIdentityResponse;
import com.viegym.admin.auth.api.AdminLoginRequest;
import com.viegym.admin.auth.api.AdminSessionResponse;
import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.RefreshToken;
import com.viegym.identity.RefreshTokenRepository;
import com.viegym.identity.SecurityRateLimitEvent;
import com.viegym.identity.SecurityRateLimitEventRepository;
import com.viegym.identity.SessionAudience;
import com.viegym.identity.TokenStatus;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import com.viegym.identity.UserRole;
import com.viegym.token.JwtAccessTokenService;
import com.viegym.token.RefreshTokenService;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminAuthService {

    private final UserRepository users;
    private final RefreshTokenRepository refreshTokens;
    private final RefreshTokenService refreshTokenService;
    private final JwtAccessTokenService jwtTokens;
    private final AdminCsrfTokenService csrfTokens;
    private final PasswordEncoder passwordEncoder;
    private final SecurityRateLimitEventRepository rateLimitEvents;
    private final Clock clock;
    private AdminAuditService audit;

    public AdminAuthService(
            UserRepository users,
            RefreshTokenRepository refreshTokens,
            RefreshTokenService refreshTokenService,
            JwtAccessTokenService jwtTokens,
            AdminCsrfTokenService csrfTokens,
            PasswordEncoder passwordEncoder,
            SecurityRateLimitEventRepository rateLimitEvents,
            Clock clock) {
        this.users = users;
        this.refreshTokens = refreshTokens;
        this.refreshTokenService = refreshTokenService;
        this.jwtTokens = jwtTokens;
        this.csrfTokens = csrfTokens;
        this.passwordEncoder = passwordEncoder;
        this.rateLimitEvents = rateLimitEvents;
        this.clock = clock;
    }

    @Autowired
    void setAudit(AdminAuditService audit) {
        this.audit = audit;
    }

    @Transactional
    public IssuedAdminSession login(AdminLoginRequest request) {
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
        boolean validCredentials =
                user != null
                        && user.authProvider() == AuthProvider.LOCAL
                        && passwordEncoder.matches(password, user.passwordHash());
        boolean validAdmin = validCredentials && user.role() == UserRole.ADMIN;
        rateLimitEvents.save(
                new SecurityRateLimitEvent(
                        SecurityRateLimitEvent.SCOPE_LOGIN,
                        csrfTokens.hash(email),
                        validAdmin,
                        now));
        if (!validAdmin) {
            recordAudit(user == null ? null : user.id(), "AUTH_LOGIN", "DENIED");
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid credentials");
        }

        ensureActiveAdmin(user);
        user.recordLogin(now);
        IssuedAdminSession session = issue(user, request.deviceInfo());
        recordAudit(user.id(), "AUTH_LOGIN", "SUCCESS");
        return session;
    }

    @Transactional(noRollbackFor = ApiException.class)
    public IssuedAdminSession refresh(String plainRefreshToken, String csrfToken) {
        RefreshToken current = findForUpdate(plainRefreshToken);
        requireAdminAudience(current);
        requireCsrf(current, csrfToken);

        OffsetDateTime now = OffsetDateTime.now(clock);
        if (current.status() == TokenStatus.REVOKED) {
            revokeReplacementChain(current, now);
            throw new ApiException(ApiErrorCode.TOKEN_REVOKED, "Refresh token was revoked");
        }
        if (current.status() == TokenStatus.EXPIRED || !now.isBefore(current.expiresAt())) {
            current.expire();
            throw new ApiException(ApiErrorCode.TOKEN_EXPIRED, "Refresh token has expired");
        }
        ensureActiveAdmin(current.user());

        IssuedAdminSession replacement = issue(current.user(), null);
        current.rotateTo(replacement.refreshToken().entity(), now);
        return replacement;
    }

    @Transactional(readOnly = true)
    public AdminSessionResponse session(
            Long authenticatedUserId, String plainRefreshToken, String csrfToken) {
        RefreshToken session = find(plainRefreshToken);
        requireAdminAudience(session);
        requireCsrf(session, csrfToken);
        if (!session.user().id().equals(authenticatedUserId)
                || session.status() != TokenStatus.ACTIVE
                || !OffsetDateTime.now(clock).isBefore(session.expiresAt())) {
            throw new ApiException(ApiErrorCode.UNAUTHENTICATED, "Admin session is not active");
        }
        ensureActiveAdmin(session.user());
        return response(session.user(), csrfToken);
    }

    @Transactional
    public void logout(String plainRefreshToken, String csrfToken) {
        if (plainRefreshToken == null || plainRefreshToken.isBlank()) {
            return;
        }
        refreshTokens
                .findByTokenHashForUpdate(refreshTokenService.hash(plainRefreshToken))
                .ifPresent(
                        token -> {
                            requireAdminAudience(token);
                            requireCsrf(token, csrfToken);
                            token.revoke(OffsetDateTime.now(clock));
                            recordAudit(token.user().id(), "AUTH_LOGOUT", "SUCCESS");
                        });
    }

    private void recordAudit(Long actorId, String action, String result) {
        if (audit != null) {
            audit.record(actorId, "ADMIN", action, "SESSION", null, result, Map.of());
        }
    }

    private IssuedAdminSession issue(User user, String deviceInfo) {
        String csrfToken = csrfTokens.issue();
        RefreshTokenService.Issued refresh =
                refreshTokenService.issue(
                        user, deviceInfo, SessionAudience.ADMIN_WEB, csrfTokens.hash(csrfToken));
        String accessToken = jwtTokens.issue(user, SessionAudience.ADMIN_WEB);
        return new IssuedAdminSession(
                accessToken, refresh, csrfToken, jwtTokens.ttlSeconds(), response(user, csrfToken));
    }

    private AdminSessionResponse response(User user, String csrfToken) {
        return new AdminSessionResponse(
                new AdminIdentityResponse(user.id(), user.email(), user.role().name()),
                jwtTokens.ttlSeconds(),
                csrfToken);
    }

    private RefreshToken findForUpdate(String plainToken) {
        if (plainToken == null || plainToken.isBlank()) {
            throw new ApiException(ApiErrorCode.UNAUTHENTICATED, "Refresh cookie is required");
        }
        return refreshTokens
                .findByTokenHashForUpdate(refreshTokenService.hash(plainToken))
                .orElseThrow(
                        () ->
                                new ApiException(
                                        ApiErrorCode.UNAUTHENTICATED, "Invalid refresh cookie"));
    }

    private RefreshToken find(String plainToken) {
        if (plainToken == null || plainToken.isBlank()) {
            throw new ApiException(ApiErrorCode.UNAUTHENTICATED, "Refresh cookie is required");
        }
        return refreshTokens
                .findByTokenHash(refreshTokenService.hash(plainToken))
                .orElseThrow(
                        () ->
                                new ApiException(
                                        ApiErrorCode.UNAUTHENTICATED, "Invalid refresh cookie"));
    }

    private void requireAdminAudience(RefreshToken token) {
        if (token.audience() != SessionAudience.ADMIN_WEB) {
            throw new ApiException(
                    ApiErrorCode.SESSION_AUDIENCE_INVALID, "Session audience is invalid");
        }
    }

    private void requireCsrf(RefreshToken token, String csrfToken) {
        if (!csrfTokens.matches(csrfToken, token.csrfSecretHash())) {
            throw new ApiException(ApiErrorCode.CSRF_INVALID, "CSRF token is invalid");
        }
    }

    private static void ensureActiveAdmin(User user) {
        if (user.role() != UserRole.ADMIN) {
            throw new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid credentials");
        }
        switch (user.status()) {
            case ACTIVE -> {}
            case PENDING ->
                    throw new ApiException(ApiErrorCode.ACCOUNT_PENDING, "Account is pending");
            case LOCKED -> throw new ApiException(ApiErrorCode.ACCOUNT_LOCKED, "Account is locked");
            case DISABLED ->
                    throw new ApiException(ApiErrorCode.ACCOUNT_DISABLED, "Account is disabled");
        }
    }

    private void revokeReplacementChain(RefreshToken token, OffsetDateTime now) {
        Long nextId = token.replacedByTokenId();
        while (nextId != null) {
            RefreshToken next = refreshTokens.findById(nextId).orElse(null);
            if (next == null) {
                return;
            }
            next.revoke(now);
            nextId = next.replacedByTokenId();
        }
    }

    private static String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }

    public record IssuedAdminSession(
            String accessToken,
            RefreshTokenService.Issued refreshToken,
            String csrfToken,
            long accessTtlSeconds,
            AdminSessionResponse response) {}
}
