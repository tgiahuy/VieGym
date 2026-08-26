package com.viegym.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.viegym.otp.FakeOtpSender;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
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
class AuthSessionAndPasswordTests {

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
    }

    @Autowired MockMvc mockMvc;
    @Autowired JdbcTemplate jdbcTemplate;
    @Autowired FakeOtpSender fakeOtpSender;

    @BeforeEach
    void cleanDatabase() {
        jdbcTemplate.update("delete from password_reset_proofs");
        jdbcTemplate.update("delete from security_rate_limit_events");
        jdbcTemplate.update("delete from refresh_tokens");
        jdbcTemplate.update("delete from otp_codes");
        jdbcTemplate.update("delete from user_profiles");
        jdbcTemplate.update("delete from users");
        fakeOtpSender.clear();
    }

    @Test
    void loginUsesGenericCredentialErrorAndEnforcesAccountStatus() throws Exception {
        register("pending@example.com", "Password123!");

        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/login",
                                loginBody("pending@example.com", "Password123!")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("ACCOUNT_PENDING"))
                .andExpect(jsonPath("$.data.accessToken").doesNotExist());

        String unknown =
                mockMvc.perform(
                                postJson(
                                        "/api/v1/auth/login",
                                        loginBody("none@example.com", "wrong")))
                        .andExpect(status().isUnauthorized())
                        .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"))
                        .andReturn()
                        .getResponse()
                        .getContentAsString();
        String wrong =
                mockMvc.perform(
                                postJson(
                                        "/api/v1/auth/login",
                                        loginBody("pending@example.com", "wrong")))
                        .andExpect(status().isUnauthorized())
                        .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"))
                        .andReturn()
                        .getResponse()
                        .getContentAsString();
        assertThat(JsonPath.<String>read(unknown, "$.message"))
                .isEqualTo(JsonPath.<String>read(wrong, "$.message"));

        activate("locked@example.com", "Password123!");
        jdbcTemplate.update(
                "update users set status = 'LOCKED' where email = 'locked@example.com'");
        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/login",
                                loginBody("locked@example.com", "Password123!")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("ACCOUNT_LOCKED"));

        activate("disabled@example.com", "Password123!");
        jdbcTemplate.update(
                "update users set status = 'DISABLED' where email = 'disabled@example.com'");
        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/login",
                                loginBody("disabled@example.com", "Password123!")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("ACCOUNT_DISABLED"));
    }

    @Test
    void refreshRotatesAndReuseRevokesReplacementFamily() throws Exception {
        Tokens initial = activate("refresh@example.com", "Password123!");
        MvcResult refreshed =
                mockMvc.perform(
                                postJson(
                                        "/api/v1/auth/refresh",
                                        """
                                        {"refreshToken":"%s","deviceInfo":"device-2"}
                                        """
                                                .formatted(initial.refreshToken())))
                        .andExpect(status().isOk())
                        .andReturn();
        String replacement =
                JsonPath.read(refreshed.getResponse().getContentAsString(), "$.data.refreshToken");
        assertThat(replacement).isNotEqualTo(initial.refreshToken());

        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/refresh",
                                "{\"refreshToken\":\"%s\"}".formatted(initial.refreshToken())))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("TOKEN_REVOKED"));

        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/refresh",
                                "{\"refreshToken\":\"%s\"}".formatted(replacement)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("TOKEN_REVOKED"));
    }

    @Test
    void logoutIsAuthenticatedAndIdempotentlyRevokesSession() throws Exception {
        Tokens tokens = activate("logout@example.com", "Password123!");
        String body = "{\"refreshToken\":\"%s\"}".formatted(tokens.refreshToken());

        mockMvc.perform(postJson("/api/v1/auth/logout", body))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
        mockMvc.perform(
                        postJson("/api/v1/auth/logout", body)
                                .header("Authorization", "Bearer " + tokens.accessToken()))
                .andExpect(status().isOk());
        mockMvc.perform(
                        postJson("/api/v1/auth/logout", body)
                                .header("Authorization", "Bearer " + tokens.accessToken()))
                .andExpect(status().isOk());

        assertThat(jdbcTemplate.queryForObject("select status from refresh_tokens", String.class))
                .isEqualTo("REVOKED");
    }

    @Test
    void forgotResetIsEnumerationSafePurposeIsolatedAndRevokesSessions() throws Exception {
        Tokens oldSession = activate("reset@example.com", "Password123!");

        String known = forgot("reset@example.com");
        String unknown = forgot("missing@example.com");
        assertThat(JsonPath.<String>read(known, "$.message"))
                .isEqualTo(JsonPath.<String>read(unknown, "$.message"));
        assertThat(JsonPath.<String>read(known, "$.data.purpose")).isEqualTo("PASSWORD_RESET");
        assertThat(JsonPath.<String>read(unknown, "$.data.purpose")).isEqualTo("PASSWORD_RESET");

        String challenge = JsonPath.read(known, "$.data.challengeId");
        String code = fakeOtpSender.lastCodeFor("reset@example.com").orElseThrow();
        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/otp/verify",
                                """
                                {"challengeId":"%s","purpose":"REGISTER","code":"%s"}
                                """
                                        .formatted(challenge, code)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));

        MvcResult verified =
                mockMvc.perform(
                                postJson(
                                        "/api/v1/auth/otp/verify",
                                        """
                                        {"challengeId":"%s","purpose":"PASSWORD_RESET","code":"%s"}
                                        """
                                                .formatted(challenge, code)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.data.resetProof").isString())
                        .andExpect(jsonPath("$.data.accessToken").isEmpty())
                        .andReturn();
        String proof =
                JsonPath.read(verified.getResponse().getContentAsString(), "$.data.resetProof");
        String resetBody =
                """
                {"resetProof":"%s","newPassword":"NewPassword456!"}
                """
                        .formatted(proof);
        mockMvc.perform(postJson("/api/v1/auth/password/reset", resetBody))
                .andExpect(status().isOk());
        mockMvc.perform(postJson("/api/v1/auth/password/reset", resetBody))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/refresh",
                                "{\"refreshToken\":\"%s\"}".formatted(oldSession.refreshToken())))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/login",
                                loginBody("reset@example.com", "NewPassword456!")))
                .andExpect(status().isOk());
    }

    @Test
    void changePasswordRequiresJwtAndRevokesExistingRefreshTokens() throws Exception {
        Tokens tokens = activate("change@example.com", "Password123!");
        String body =
                """
                {"currentPassword":"Password123!","newPassword":"Changed456!"}
                """;
        mockMvc.perform(postJson("/api/v1/auth/password/change", body))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(
                        postJson("/api/v1/auth/password/change", body)
                                .header("Authorization", "Bearer " + tokens.accessToken()))
                .andExpect(status().isOk());
        mockMvc.perform(
                        postJson(
                                "/api/v1/auth/login",
                                loginBody("change@example.com", "Changed456!")))
                .andExpect(status().isOk());
    }

    @Test
    void securityPolicyRejectsInvalidJwtAndUserRoleOnAdminPaths() throws Exception {
        Tokens tokens = activate("policy@example.com", "Password123!");
        mockMvc.perform(get("/api/v1/private/probe"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
        mockMvc.perform(get("/api/v1/private/probe").header("Authorization", "Bearer broken.jwt"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(
                        get("/api/v1/admin/probe")
                                .header("Authorization", "Bearer " + tokens.accessToken()))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("ACCESS_DENIED"));
        mockMvc.perform(postJson("/api/v1/auth/google", "{\"idToken\":\"not-a-google-token\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"));
    }

    private String forgot(String email) throws Exception {
        return mockMvc.perform(
                        postJson(
                                "/api/v1/auth/password/forgot",
                                "{\"email\":\"%s\"}".formatted(email)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
    }

    private Tokens activate(String email, String password) throws Exception {
        String challenge = register(email, password);
        String code = fakeOtpSender.lastCodeFor(email).orElseThrow();
        MvcResult result =
                mockMvc.perform(
                                postJson(
                                        "/api/v1/auth/otp/verify",
                                        "{\"challengeId\":\"%s\",\"purpose\":\"REGISTER\",\"code\":\"%s\"}"
                                                .formatted(challenge, code)))
                        .andExpect(status().isOk())
                        .andReturn();
        String json = result.getResponse().getContentAsString();
        return new Tokens(
                JsonPath.read(json, "$.data.accessToken"),
                JsonPath.read(json, "$.data.refreshToken"));
    }

    private String register(String email, String password) throws Exception {
        MvcResult result =
                mockMvc.perform(
                                postJson(
                                        "/api/v1/auth/register",
                                        """
                                        {"displayName":"Test User","email":"%s","password":"%s"}
                                        """
                                                .formatted(email, password)))
                        .andExpect(status().isCreated())
                        .andReturn();
        return JsonPath.read(result.getResponse().getContentAsString(), "$.data.challengeId");
    }

    private static String loginBody(String email, String password) {
        return """
               {"email":"%s","password":"%s","deviceInfo":"test-device"}
               """
                .formatted(email, password);
    }

    private static org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
            postJson(String path, String body) {
        return post(path).contentType(APPLICATION_JSON).content(body);
    }

    private record Tokens(String accessToken, String refreshToken) {}
}
