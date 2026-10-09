package com.viegym.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.admin.auth.web.AdminCookieService;
import com.viegym.admin.auth.web.AdminCsrfFilter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.Cookie;
import java.time.Clock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

class AdminCsrfFilterTest {

    private AdminCsrfFilter filter;
    private AdminCookieService cookieService;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        cookieService = new AdminCookieService(true, Clock.systemUTC());
        objectMapper = new ObjectMapper().findAndRegisterModules();
        filter = new AdminCsrfFilter(cookieService, objectMapper);
    }

    @Test
    void allowsGetRequestsWithoutCsrf() throws Exception {
        MockHttpServletRequest request =
                new MockHttpServletRequest("GET", "/api/v1/admin/auth/csrf");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = mock(FilterChain.class);

        filter.doFilter(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
    }

    @Test
    void allowsPostWithMatchingCookieAndHeader() throws Exception {
        MockHttpServletRequest request =
                new MockHttpServletRequest("POST", "/api/v1/admin/auth/login");
        request.setCookies(new Cookie(AdminCookieService.CSRF_COOKIE, "csrf_123456"));
        request.addHeader(AdminCookieService.CSRF_HEADER, "csrf_123456");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = mock(FilterChain.class);

        filter.doFilter(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
    }

    @Test
    void blocksPostWithMissingOrMismatchedCsrf() throws Exception {
        MockHttpServletRequest request =
                new MockHttpServletRequest("POST", "/api/v1/admin/auth/login");
        request.setCookies(new Cookie(AdminCookieService.CSRF_COOKIE, "csrf_123456"));
        request.addHeader(AdminCookieService.CSRF_HEADER, "wrong_token");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = mock(FilterChain.class);

        filter.doFilter(request, response, filterChain);

        verify(filterChain, never()).doFilter(request, response);
        assertThat(response.getStatus()).isEqualTo(403);
        assertThat(response.getContentAsString()).contains("CSRF_INVALID");
    }
}
