package com.viegym.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.viegym.admin.auth.api.AdminLoginRequest;
import com.viegym.admin.auth.application.AdminAuthService;
import com.viegym.admin.auth.application.AdminAuthService.IssuedAdminSession;
import com.viegym.admin.auth.application.AdminCsrfTokenService;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.common.error.ApiValidationException;
import com.viegym.identity.RefreshToken;
import com.viegym.identity.RefreshTokenRepository;
import com.viegym.identity.SecurityRateLimitEvent;
import com.viegym.identity.SecurityRateLimitEventRepository;
import com.viegym.identity.SessionAudience;
import com.viegym.identity.TokenStatus;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import com.viegym.token.JwtAccessTokenService;
import com.viegym.token.RefreshTokenService;
import java.lang.reflect.Field;
import java.time.Clock;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

class AdminAuthServiceTest {

    private UserRepository users;
    private RefreshTokenRepository refreshTokens;
    private RefreshTokenService refreshTokenService;
    private JwtAccessTokenService jwtTokens;
    private AdminCsrfTokenService csrfTokens;
    private PasswordEncoder passwordEncoder;
    private SecurityRateLimitEventRepository rateLimitEvents;
    private Clock clock;
    private AdminAuthService service;

    private final Instant fixedInstant = Instant.parse("2026-10-03T10:00:00Z");

    @BeforeEach
    void setUp() {
        users = mock(UserRepository.class);
        refreshTokens = mock(RefreshTokenRepository.class);
        refreshTokenService = mock(RefreshTokenService.class);
        jwtTokens = mock(JwtAccessTokenService.class);
        csrfTokens = new AdminCsrfTokenService();
        passwordEncoder = mock(PasswordEncoder.class);
        rateLimitEvents = mock(SecurityRateLimitEventRepository.class);
        clock = Clock.fixed(fixedInstant, ZoneOffset.UTC);

        service =
                new AdminAuthService(
                        users,
                        refreshTokens,
                        refreshTokenService,
                        jwtTokens,
                        csrfTokens,
                        passwordEncoder,
                        rateLimitEvents,
                        clock);
    }

    @Test
    void loginSuccessForActiveAdmin() throws Exception {
        User admin = User.localAdmin("admin@viegym.test", "encoded_pw", OffsetDateTime.now(clock));
        setId(admin, 1L);
        when(users.findByEmail("admin@viegym.test")).thenReturn(Optional.of(admin));
        when(passwordEncoder.matches("ValidPassword123!", "encoded_pw")).thenReturn(true);
        when(jwtTokens.issue(admin, SessionAudience.ADMIN_WEB)).thenReturn("jwt_access_token");
        when(jwtTokens.ttlSeconds()).thenReturn(900L);

        RefreshToken tokenEntity =
                new RefreshToken(
                        admin,
                        "token_hash",
                        SessionAudience.ADMIN_WEB,
                        "Chrome/macOS",
                        "csrf_hash",
                        OffsetDateTime.now(clock).plusDays(7),
                        OffsetDateTime.now(clock));
        when(refreshTokenService.issue(
                        eq(admin), eq("Chrome/macOS"), eq(SessionAudience.ADMIN_WEB), any()))
                .thenReturn(new RefreshTokenService.Issued("plain_refresh_token", tokenEntity));

        IssuedAdminSession session =
                service.login(
                        new AdminLoginRequest(
                                "admin@viegym.test", "ValidPassword123!", "Chrome/macOS"));

        assertThat(session.accessToken()).isEqualTo("jwt_access_token");
        assertThat(session.refreshToken().plainToken()).isEqualTo("plain_refresh_token");
        assertThat(session.csrfToken()).isNotBlank();
        assertThat(session.response().admin().email()).isEqualTo("admin@viegym.test");
        assertThat(session.response().admin().role()).isEqualTo("ADMIN");

        verify(rateLimitEvents).save(any(SecurityRateLimitEvent.class));
    }

    @Test
    void loginFailsWithGenericInvalidCredentialsForNormalUser() {
        User regularUser = new User("user@viegym.test", "encoded_pw");
        when(users.findByEmail("user@viegym.test")).thenReturn(Optional.of(regularUser));
        when(passwordEncoder.matches("Pass1234", "encoded_pw")).thenReturn(true);

        assertThatThrownBy(
                        () ->
                                service.login(
                                        new AdminLoginRequest(
                                                "user@viegym.test", "Pass1234", "Chrome")))
                .isInstanceOf(ApiException.class)
                .satisfies(
                        ex ->
                                assertThat(((ApiException) ex).code())
                                        .isEqualTo(ApiErrorCode.INVALID_CREDENTIALS));
    }

    @Test
    void loginFailsWhenCredentialsAreBlank() {
        assertThatThrownBy(() -> service.login(new AdminLoginRequest("", "", "")))
                .isInstanceOf(ApiValidationException.class);
    }

    @Test
    void refreshFailsIfCsrfDoesNotMatch() {
        User admin = User.localAdmin("admin@viegym.test", "encoded_pw", OffsetDateTime.now(clock));
        String csrfSecretHash = csrfTokens.hash("correct_csrf_token");
        RefreshToken token =
                new RefreshToken(
                        admin,
                        "hash123",
                        SessionAudience.ADMIN_WEB,
                        "device",
                        csrfSecretHash,
                        OffsetDateTime.now(clock).plusDays(7),
                        OffsetDateTime.now(clock));

        when(refreshTokenService.hash("plain_token")).thenReturn("hash123");
        when(refreshTokens.findByTokenHashForUpdate("hash123")).thenReturn(Optional.of(token));

        assertThatThrownBy(() -> service.refresh("plain_token", "wrong_csrf_token"))
                .isInstanceOf(ApiException.class)
                .satisfies(
                        ex ->
                                assertThat(((ApiException) ex).code())
                                        .isEqualTo(ApiErrorCode.CSRF_INVALID));
    }

    @Test
    void refreshFailsIfAudienceIsNotAdminWeb() {
        User user = new User("user@viegym.test", "hash");
        RefreshToken token =
                new RefreshToken(
                        user,
                        "hash123",
                        SessionAudience.MOBILE_USER,
                        "device",
                        null,
                        OffsetDateTime.now(clock).plusDays(7),
                        OffsetDateTime.now(clock));

        when(refreshTokenService.hash("plain_token")).thenReturn("hash123");
        when(refreshTokens.findByTokenHashForUpdate("hash123")).thenReturn(Optional.of(token));

        assertThatThrownBy(() -> service.refresh("plain_token", "csrf"))
                .isInstanceOf(ApiException.class)
                .satisfies(
                        ex ->
                                assertThat(((ApiException) ex).code())
                                        .isEqualTo(ApiErrorCode.SESSION_AUDIENCE_INVALID));
    }

    @Test
    void logoutRevokesToken() {
        User admin = User.localAdmin("admin@viegym.test", "encoded_pw", OffsetDateTime.now(clock));
        String csrfToken = "csrf_token_value";
        RefreshToken token =
                new RefreshToken(
                        admin,
                        "hash123",
                        SessionAudience.ADMIN_WEB,
                        "device",
                        csrfTokens.hash(csrfToken),
                        OffsetDateTime.now(clock).plusDays(7),
                        OffsetDateTime.now(clock));

        when(refreshTokenService.hash("plain_token")).thenReturn("hash123");
        when(refreshTokens.findByTokenHashForUpdate("hash123")).thenReturn(Optional.of(token));

        service.logout("plain_token", csrfToken);
        assertThat(token.status()).isEqualTo(TokenStatus.REVOKED);
    }

    private static void setId(User user, Long id) throws Exception {
        Field idField = User.class.getDeclaredField("id");
        idField.setAccessible(true);
        idField.set(user, id);
    }
}
