package com.viegym.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.viegym.identity.AccountStatus;
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
class AuthOtpVerifyTests {

    @Container
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:16.14-bookworm")
                    .withDatabaseName("viegym_test")
                    .withUsername("viegym_test")
                    .withPassword("test_password");

    @DynamicPropertySource
    static void datasourceProperties(DynamicPropertyRegistry registry) {
        registry.add("SPRING_DATASOURCE_URL", POSTGRES::getJdbcUrl);
        registry.add("SPRING_DATASOURCE_USERNAME", POSTGRES::getUsername);
        registry.add("SPRING_DATASOURCE_PASSWORD", POSTGRES::getPassword);
    }

    @Autowired MockMvc mockMvc;
    @Autowired JdbcTemplate jdbcTemplate;
    @Autowired FakeOtpSender fakeOtpSender;

    @BeforeEach
    void cleanDatabase() {
        jdbcTemplate.update("delete from security_rate_limit_events");
        jdbcTemplate.update("delete from refresh_tokens");
        jdbcTemplate.update("delete from otp_codes");
        jdbcTemplate.update("delete from user_profiles");
        jdbcTemplate.update("delete from users");
        fakeOtpSender.clear();
    }

    // -----------------------------------------------------------------------
    // Happy path
    // -----------------------------------------------------------------------

    @Test
    void verifyValidOtpActivatesAccountAndGrantsSession() throws Exception {
        String email = "an@example.com";
        String challengeId = registerAndGetChallengeId("An", email, "Password123!");
        String code = fakeOtpSender.lastCodeFor(email).orElseThrow();

        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, code)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Account verified successfully"))
                .andExpect(jsonPath("$.data.accessToken").isString())
                .andExpect(jsonPath("$.data.refreshToken").isString())
                .andExpect(jsonPath("$.data.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.data.expiresIn").isNumber());

        // User is now ACTIVE with email_verified_at set.
        String status =
                jdbcTemplate.queryForObject(
                        "select status from users where email = ?", String.class, email);
        assertThat(status).isEqualTo(AccountStatus.ACTIVE.name());

        Boolean emailVerified =
                jdbcTemplate.queryForObject(
                        "select email_verified_at is not null from users where email = ?",
                        Boolean.class,
                        email);
        assertThat(emailVerified).isTrue();

        // OTP is consumed.
        Boolean consumed =
                jdbcTemplate.queryForObject(
                        "select consumed_at is not null from otp_codes where destination = ?",
                        Boolean.class,
                        email);
        assertThat(consumed).isTrue();

        // A refresh token record was created.
        Integer refreshCount =
                jdbcTemplate.queryForObject(
                        "select count(*) from refresh_tokens rt"
                                + " join users u on u.id = rt.user_id"
                                + " where u.email = ?",
                        Integer.class,
                        email);
        assertThat(refreshCount).isEqualTo(1);
    }

    // -----------------------------------------------------------------------
    // Error cases
    // -----------------------------------------------------------------------

    @Test
    void wrongCodeReturnsOtpInvalid() throws Exception {
        String email = "wrong@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");

        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, "000000")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));

        // Attempt count was persisted (noRollbackFor contract).
        Integer attempts =
                jdbcTemplate.queryForObject(
                        "select attempt_count from otp_codes where destination = ?",
                        Integer.class,
                        email);
        assertThat(attempts).isEqualTo(1);
    }

    @Test
    void maxAttemptsExceededReturnsOtpAttemptsExceeded() throws Exception {
        String email = "limit@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");

        // Set attempt_count = max_attempts so the very next call is already over the limit.
        jdbcTemplate.update(
                "update otp_codes set attempt_count = max_attempts where destination = ?", email);

        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, "000000")))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("OTP_ATTEMPTS_EXCEEDED"));
    }

    @Test
    void expiredOtpReturnsOtpExpired() throws Exception {
        String email = "expired@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");
        String code = fakeOtpSender.lastCodeFor(email).orElseThrow();

        // Wind the clock back so the OTP looks expired.
        jdbcTemplate.update(
                "update otp_codes set expires_at = now() - interval '1 minute' where destination = ?",
                email);

        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, code)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_EXPIRED"));
    }

    @Test
    void alreadyConsumedOtpReturnsOtpInvalid() throws Exception {
        String email = "consumed@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");
        String code = fakeOtpSender.lastCodeFor(email).orElseThrow();

        // First verify — must succeed.
        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, code)))
                .andExpect(status().isOk());

        // Second verify with the same code — must be rejected.
        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, code)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));
    }

    @Test
    void unknownChallengeIdReturnsOtpInvalid() throws Exception {
        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody("otp_9999999", "123456")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private String registerAndGetChallengeId(String displayName, String email, String password)
            throws Exception {
        MvcResult result =
                mockMvc.perform(
                                post("/api/v1/auth/register")
                                        .contentType(APPLICATION_JSON)
                                        .content(
                                                """
                                                {"displayName":"%s","email":"%s","password":"%s"}
                                                """
                                                        .formatted(displayName, email, password)))
                        .andExpect(status().isCreated())
                        .andReturn();
        return JsonPath.read(result.getResponse().getContentAsString(), "$.data.challengeId");
    }

    private static String verifyBody(String challengeId, String code) {
        return """
               {"challengeId":"%s","code":"%s"}
               """
                .formatted(challengeId, code);
    }
}
