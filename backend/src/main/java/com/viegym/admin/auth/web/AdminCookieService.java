package com.viegym.admin.auth.web;

import com.viegym.admin.auth.application.AdminAuthService.IssuedAdminSession;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Component;

@Component
public class AdminCookieService {

    public static final String ACCESS_COOKIE = "viegym_admin_access";
    public static final String REFRESH_COOKIE = "viegym_admin_refresh";
    public static final String CSRF_COOKIE = "viegym_admin_csrf";
    public static final String CSRF_HEADER = "X-CSRF-TOKEN";

    private static final String ADMIN_PATH = "/api/v1/admin";
    private static final String AUTH_PATH = "/api/v1/admin/auth";

    private final boolean secure;
    private final Clock clock;

    public AdminCookieService(
            @Value("${admin.cookie.secure:${ADMIN_COOKIE_SECURE:true}}") boolean secure,
            Clock clock) {
        this.secure = secure;
        this.clock = clock;
    }

    public void writeSession(HttpServletResponse response, IssuedAdminSession session) {
        add(
                response,
                cookie(ACCESS_COOKIE, session.accessToken(), ADMIN_PATH)
                        .httpOnly(true)
                        .maxAge(Duration.ofSeconds(session.accessTtlSeconds()))
                        .build());

        Duration refreshTtl =
                Duration.between(
                        OffsetDateTime.now(clock), session.refreshToken().entity().expiresAt());
        add(
                response,
                cookie(REFRESH_COOKIE, session.refreshToken().plainToken(), AUTH_PATH)
                        .httpOnly(true)
                        .maxAge(refreshTtl.isNegative() ? Duration.ZERO : refreshTtl)
                        .build());
        writeCsrf(response, session.csrfToken());
    }

    public void writeCsrf(HttpServletResponse response, String token) {
        add(
                response,
                cookie(CSRF_COOKIE, token, ADMIN_PATH)
                        .httpOnly(false)
                        .maxAge(Duration.ofHours(8))
                        .build());
    }

    public void clearSession(HttpServletResponse response) {
        add(response, expired(ACCESS_COOKIE, ADMIN_PATH, true));
        add(response, expired(REFRESH_COOKIE, AUTH_PATH, true));
        add(response, expired(CSRF_COOKIE, ADMIN_PATH, false));
    }

    public String read(HttpServletRequest request, String cookieName) {
        if (request.getCookies() == null) {
            return null;
        }
        return Arrays.stream(request.getCookies())
                .filter(cookie -> cookieName.equals(cookie.getName()))
                .map(Cookie::getValue)
                .findFirst()
                .orElse(null);
    }

    private ResponseCookie.ResponseCookieBuilder cookie(String name, String value, String path) {
        return ResponseCookie.from(name, value).secure(secure).sameSite("Strict").path(path);
    }

    private ResponseCookie expired(String name, String path, boolean httpOnly) {
        return cookie(name, "", path).httpOnly(httpOnly).maxAge(Duration.ZERO).build();
    }

    private static void add(HttpServletResponse response, ResponseCookie cookie) {
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }
}
