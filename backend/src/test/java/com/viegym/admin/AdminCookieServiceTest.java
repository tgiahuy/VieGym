package com.viegym.admin;

import static org.assertj.core.api.Assertions.assertThat;

import com.viegym.admin.auth.api.AdminIdentityResponse;
import com.viegym.admin.auth.api.AdminSessionResponse;
import com.viegym.admin.auth.application.AdminAuthService.IssuedAdminSession;
import com.viegym.admin.auth.web.AdminCookieService;
import com.viegym.identity.RefreshToken;
import com.viegym.identity.SessionAudience;
import com.viegym.identity.User;
import com.viegym.token.RefreshTokenService;
import jakarta.servlet.http.Cookie;
import java.time.Clock;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

class AdminCookieServiceTest {

    private AdminCookieService cookieService;
    private Clock clock;
    private final Instant now = Instant.parse("2026-10-03T10:00:00Z");

    @BeforeEach
    void setUp() {
        clock = Clock.fixed(now, ZoneOffset.UTC);
        cookieService = new AdminCookieService(true, clock);
    }

    @Test
    void writesSecureAndHttpOnlyCookiesForSession() {
        MockHttpServletResponse response = new MockHttpServletResponse();
        User user = User.localAdmin("admin@viegym.test", "pw", OffsetDateTime.now(clock));
        RefreshToken entity =
                new RefreshToken(
                        user,
                        "hash",
                        SessionAudience.ADMIN_WEB,
                        "device",
                        "csrf_hash",
                        OffsetDateTime.now(clock).plusDays(7),
                        OffsetDateTime.now(clock));

        IssuedAdminSession session =
                new IssuedAdminSession(
                        "access_jwt_value",
                        new RefreshTokenService.Issued("plain_refresh_value", entity),
                        "csrf_token_value",
                        900L,
                        new AdminSessionResponse(
                                new AdminIdentityResponse(1L, "admin@viegym.test", "ADMIN"),
                                900L,
                                "csrf_token_value"));

        cookieService.writeSession(response, session);

        List<String> setCookies = response.getHeaders("Set-Cookie");
        assertThat(setCookies).hasSize(3);

        String accessCookie =
                setCookies.stream()
                        .filter(s -> s.startsWith(AdminCookieService.ACCESS_COOKIE + "="))
                        .findFirst()
                        .orElseThrow();
        assertThat(accessCookie)
                .contains("HttpOnly")
                .contains("Secure")
                .contains("SameSite=Strict")
                .contains("Path=/api/v1/admin");

        String refreshCookie =
                setCookies.stream()
                        .filter(s -> s.startsWith(AdminCookieService.REFRESH_COOKIE + "="))
                        .findFirst()
                        .orElseThrow();
        assertThat(refreshCookie)
                .contains("HttpOnly")
                .contains("Secure")
                .contains("SameSite=Strict")
                .contains("Path=/api/v1/admin/auth");

        String csrfCookie =
                setCookies.stream()
                        .filter(s -> s.startsWith(AdminCookieService.CSRF_COOKIE + "="))
                        .findFirst()
                        .orElseThrow();
        assertThat(csrfCookie)
                .doesNotContain("HttpOnly") // CSRF cookie must be readable by JS
                .contains("Secure")
                .contains("SameSite=Strict")
                .contains("Path=/api/v1/admin");
    }

    @Test
    void clearSessionSetsMaxAgeZero() {
        MockHttpServletResponse response = new MockHttpServletResponse();
        cookieService.clearSession(response);

        List<String> setCookies = response.getHeaders("Set-Cookie");
        assertThat(setCookies).hasSize(3);
        assertThat(setCookies).allMatch(s -> s.contains("Max-Age=0"));
    }

    @Test
    void readCookie() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setCookies(new Cookie(AdminCookieService.ACCESS_COOKIE, "sample_token"));

        assertThat(cookieService.read(request, AdminCookieService.ACCESS_COOKIE))
                .isEqualTo("sample_token");
        assertThat(cookieService.read(request, AdminCookieService.REFRESH_COOKIE)).isNull();
    }
}
