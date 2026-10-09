package com.viegym.admin.auth.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.api.ApiErrorResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.observability.CorrelationId;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AdminCsrfFilter extends OncePerRequestFilter {

    private final AdminCookieService cookies;
    private final ObjectMapper objectMapper;

    public AdminCsrfFilter(AdminCookieService cookies, ObjectMapper objectMapper) {
        this.cookies = cookies;
        this.objectMapper = objectMapper;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        if (!request.getRequestURI().startsWith("/api/v1/admin/")) {
            return true;
        }
        return switch (request.getMethod()) {
            case "GET", "HEAD", "OPTIONS", "TRACE" -> true;
            default -> false;
        };
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String cookieToken = cookies.read(request, AdminCookieService.CSRF_COOKIE);
        String headerToken = request.getHeader(AdminCookieService.CSRF_HEADER);
        if (!matches(cookieToken, headerToken)) {
            response.setStatus(ApiErrorCode.CSRF_INVALID.httpStatus().value());
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            objectMapper.writeValue(
                    response.getWriter(),
                    ApiErrorResponse.of(
                            ApiErrorCode.CSRF_INVALID.name(),
                            "CSRF token is missing or invalid",
                            List.of(),
                            CorrelationId.currentOrCreate()));
            return;
        }
        filterChain.doFilter(request, response);
    }

    private static boolean matches(String cookieToken, String headerToken) {
        if (cookieToken == null
                || cookieToken.isBlank()
                || headerToken == null
                || headerToken.isBlank()) {
            return false;
        }
        return MessageDigest.isEqual(
                cookieToken.getBytes(StandardCharsets.UTF_8),
                headerToken.getBytes(StandardCharsets.UTF_8));
    }
}
