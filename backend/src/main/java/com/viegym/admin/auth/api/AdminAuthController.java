package com.viegym.admin.auth.api;

import com.viegym.admin.auth.application.AdminAuthService;
import com.viegym.admin.auth.application.AdminAuthService.IssuedAdminSession;
import com.viegym.admin.auth.application.AdminCsrfTokenService;
import com.viegym.admin.auth.web.AdminCookieService;
import com.viegym.common.api.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/auth")
public class AdminAuthController {

    private final AdminAuthService authService;
    private final AdminCsrfTokenService csrfTokens;
    private final AdminCookieService cookies;

    public AdminAuthController(
            AdminAuthService authService,
            AdminCsrfTokenService csrfTokens,
            AdminCookieService cookies) {
        this.authService = authService;
        this.csrfTokens = csrfTokens;
        this.cookies = cookies;
    }

    @GetMapping("/csrf")
    ResponseEntity<ApiResponse<AdminCsrfResponse>> csrf(
            HttpServletRequest request, HttpServletResponse response) {
        String token = cookies.read(request, AdminCookieService.CSRF_COOKIE);
        if (token == null || token.isBlank()) {
            token = csrfTokens.issue();
            cookies.writeCsrf(response, token);
        }
        return noStore(ApiResponse.success(new AdminCsrfResponse(token)));
    }

    @PostMapping("/login")
    ResponseEntity<ApiResponse<AdminSessionResponse>> login(
            @RequestBody AdminLoginRequest request, HttpServletResponse response) {
        IssuedAdminSession session = authService.login(request);
        cookies.writeSession(response, session);
        return noStore(ApiResponse.success(session.response()));
    }

    @PostMapping("/refresh")
    ResponseEntity<ApiResponse<AdminSessionResponse>> refresh(
            HttpServletRequest request,
            HttpServletResponse response,
            @RequestHeader(AdminCookieService.CSRF_HEADER) String csrfToken) {
        IssuedAdminSession session =
                authService.refresh(
                        cookies.read(request, AdminCookieService.REFRESH_COOKIE), csrfToken);
        cookies.writeSession(response, session);
        return noStore(ApiResponse.success(session.response()));
    }

    @PostMapping("/logout")
    ResponseEntity<ApiResponse<Void>> logout(
            HttpServletRequest request,
            HttpServletResponse response,
            @RequestHeader(AdminCookieService.CSRF_HEADER) String csrfToken) {
        authService.logout(cookies.read(request, AdminCookieService.REFRESH_COOKIE), csrfToken);
        cookies.clearSession(response);
        return noStore(ApiResponse.success(null));
    }

    @GetMapping("/session")
    ResponseEntity<ApiResponse<AdminSessionResponse>> session(
            HttpServletRequest request, @AuthenticationPrincipal Jwt jwt) {
        AdminSessionResponse session =
                authService.session(
                        Long.valueOf(jwt.getSubject()),
                        cookies.read(request, AdminCookieService.REFRESH_COOKIE),
                        cookies.read(request, AdminCookieService.CSRF_COOKIE));
        return noStore(ApiResponse.success(session));
    }

    private static <T> ResponseEntity<ApiResponse<T>> noStore(ApiResponse<T> body) {
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(body);
    }
}
