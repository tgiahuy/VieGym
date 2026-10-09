package com.viegym.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.viegym.admin.auth.web.AdminCookieService;
import com.viegym.identity.User;
import com.viegym.identity.UserRepository;
import jakarta.servlet.http.Cookie;
import java.time.OffsetDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
class AdminAuthIntegrationTests {

    private static final String ADMIN_EMAIL = "admin@viegym.test";
    private static final String ADMIN_PASSWORD = "StrongAdminPassword123!";

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_test")
                    .withUsername("viegym_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
        registry.add("ADMIN_COOKIE_SECURE", () -> true);
    }

    @Autowired MockMvc mockMvc;
    @Autowired JdbcTemplate jdbcTemplate;
    @Autowired UserRepository users;
    @Autowired PasswordEncoder passwordEncoder;

    @BeforeEach
    void setup() {
        jdbcTemplate.update("delete from security_rate_limit_events");
        jdbcTemplate.update("delete from refresh_tokens");
        jdbcTemplate.update("delete from otp_codes");
        jdbcTemplate.update("delete from user_profiles");
        jdbcTemplate.update("delete from users");
        users.saveAndFlush(
                User.localAdmin(
                        ADMIN_EMAIL, passwordEncoder.encode(ADMIN_PASSWORD), OffsetDateTime.now()));
    }

    @Test
    void loginIssuesStrictSecureCookiesAndDoesNotExposeTokensInJson() throws Exception {
        Csrf csrf = csrf();
        MvcResult result =
                login(csrf, ADMIN_EMAIL, ADMIN_PASSWORD)
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.admin.email").value(ADMIN_EMAIL))
                        .andExpect(jsonPath("$.data.admin.role").value("ADMIN"))
                        .andExpect(jsonPath("$.data.expiresIn").isNumber())
                        .andExpect(jsonPath("$.data.csrfToken").isString())
                        .andExpect(jsonPath("$.data.accessToken").doesNotExist())
                        .andExpect(jsonPath("$.data.refreshToken").doesNotExist())
                        .andReturn();

        Cookie access = requiredCookie(result, AdminCookieService.ACCESS_COOKIE);
        Cookie refresh = requiredCookie(result, AdminCookieService.REFRESH_COOKIE);
        Cookie rotatedCsrf = requiredCookie(result, AdminCookieService.CSRF_COOKIE);
        assertThat(access.isHttpOnly()).isTrue();
        assertThat(refresh.isHttpOnly()).isTrue();
        assertThat(rotatedCsrf.isHttpOnly()).isFalse();
        assertThat(access.getSecure()).isTrue();
        assertThat(refresh.getSecure()).isTrue();

        List<String> setCookies = result.getResponse().getHeaders("Set-Cookie");
        assertThat(setCookies)
                .filteredOn(header -> header.startsWith(AdminCookieService.ACCESS_COOKIE + "="))
                .singleElement()
                .asString()
                .contains("HttpOnly", "Secure", "SameSite=Strict");
        assertThat(setCookies)
                .filteredOn(header -> header.startsWith(AdminCookieService.REFRESH_COOKIE + "="))
                .singleElement()
                .asString()
                .contains("HttpOnly", "Secure", "SameSite=Strict");

        assertThat(jdbcTemplate.queryForObject("select audience from refresh_tokens", String.class))
                .isEqualTo("ADMIN_WEB");
        String storedCsrfHash =
                jdbcTemplate.queryForObject(
                        "select csrf_secret_hash from refresh_tokens", String.class);
        assertThat(storedCsrfHash).hasSize(64).isNotEqualTo(rotatedCsrf.getValue());
    }

    @Test
    void validUserCredentialsReceiveGenericAdminLoginFailure() throws Exception {
        User user = new User("user@viegym.test", passwordEncoder.encode(ADMIN_PASSWORD));
        user.activate(OffsetDateTime.now());
        users.saveAndFlush(user);

        Csrf csrf = csrf();
        login(csrf, "user@viegym.test", ADMIN_PASSWORD)
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    @Test
    void csrfIsRequiredForAdminMutations() throws Exception {
        mockMvc.perform(
                        post("/api/v1/admin/auth/login")
                                .contentType(APPLICATION_JSON)
                                .content(loginBody(ADMIN_EMAIL, ADMIN_PASSWORD)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("CSRF_INVALID"));
    }

    @Test
    void sessionBootstrapsFromAdminCookies() throws Exception {
        LoginCookies session = loginCookies();

        mockMvc.perform(
                        get("/api/v1/admin/auth/session")
                                .cookie(session.access(), session.refresh(), session.csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.admin.id").isNumber())
                .andExpect(jsonPath("$.data.admin.role").value("ADMIN"))
                .andExpect(jsonPath("$.data.csrfToken").value(session.csrf().getValue()));
    }

    @Test
    void refreshRotatesCookiesAndReuseRevokesReplacement() throws Exception {
        LoginCookies initial = loginCookies();
        MvcResult refreshed =
                mockMvc.perform(
                                post("/api/v1/admin/auth/refresh")
                                        .cookie(initial.refresh(), initial.csrf())
                                        .header(
                                                AdminCookieService.CSRF_HEADER,
                                                initial.csrf().getValue()))
                        .andExpect(status().isOk())
                        .andReturn();

        Cookie replacementRefresh = requiredCookie(refreshed, AdminCookieService.REFRESH_COOKIE);
        Cookie replacementCsrf = requiredCookie(refreshed, AdminCookieService.CSRF_COOKIE);
        assertThat(replacementRefresh.getValue()).isNotEqualTo(initial.refresh().getValue());
        assertThat(replacementCsrf.getValue()).isNotEqualTo(initial.csrf().getValue());

        mockMvc.perform(
                        post("/api/v1/admin/auth/refresh")
                                .cookie(initial.refresh(), initial.csrf())
                                .header(AdminCookieService.CSRF_HEADER, initial.csrf().getValue()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("TOKEN_REVOKED"));

        Integer active =
                jdbcTemplate.queryForObject(
                        "select count(*) from refresh_tokens where status = 'ACTIVE'",
                        Integer.class);
        assertThat(active).isZero();
    }

    @Test
    void logoutRevokesRefreshTokenAndClearsCookies() throws Exception {
        LoginCookies session = loginCookies();

        MvcResult result =
                mockMvc.perform(
                                post("/api/v1/admin/auth/logout")
                                        .cookie(session.refresh(), session.csrf())
                                        .header(
                                                AdminCookieService.CSRF_HEADER,
                                                session.csrf().getValue()))
                        .andExpect(status().isOk())
                        .andReturn();

        assertThat(jdbcTemplate.queryForObject("select status from refresh_tokens", String.class))
                .isEqualTo("REVOKED");
        assertThat(requiredCookie(result, AdminCookieService.ACCESS_COOKIE).getMaxAge()).isZero();
        assertThat(requiredCookie(result, AdminCookieService.REFRESH_COOKIE).getMaxAge()).isZero();
        assertThat(requiredCookie(result, AdminCookieService.CSRF_COOKIE).getMaxAge()).isZero();
    }

    private Csrf csrf() throws Exception {
        MvcResult result =
                mockMvc.perform(get("/api/v1/admin/auth/csrf"))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.csrfToken").isString())
                        .andReturn();
        String token = JsonPath.read(result.getResponse().getContentAsString(), "$.data.csrfToken");
        return new Csrf(token, requiredCookie(result, AdminCookieService.CSRF_COOKIE));
    }

    private org.springframework.test.web.servlet.ResultActions login(
            Csrf csrf, String email, String password) throws Exception {
        return mockMvc.perform(
                post("/api/v1/admin/auth/login")
                        .contentType(APPLICATION_JSON)
                        .cookie(csrf.cookie())
                        .header(AdminCookieService.CSRF_HEADER, csrf.token())
                        .content(loginBody(email, password)));
    }

    private LoginCookies loginCookies() throws Exception {
        MvcResult result =
                login(csrf(), ADMIN_EMAIL, ADMIN_PASSWORD).andExpect(status().isOk()).andReturn();
        return new LoginCookies(
                requiredCookie(result, AdminCookieService.ACCESS_COOKIE),
                requiredCookie(result, AdminCookieService.REFRESH_COOKIE),
                requiredCookie(result, AdminCookieService.CSRF_COOKIE));
    }

    private static Cookie requiredCookie(MvcResult result, String name) {
        Cookie cookie = result.getResponse().getCookie(name);
        assertThat(cookie).as("response cookie %s", name).isNotNull();
        return cookie;
    }

    private static String loginBody(String email, String password) {
        return """
               {"email":"%s","password":"%s","deviceInfo":"admin-web-test"}
               """
                .formatted(email, password);
    }

    private record Csrf(String token, Cookie cookie) {}

    private record LoginCookies(Cookie access, Cookie refresh, Cookie csrf) {}
}
