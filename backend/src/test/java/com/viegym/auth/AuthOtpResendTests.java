package com.viegym.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.viegym.identity.OtpPurpose;
import com.viegym.otp.FakeOtpSender;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;
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
class AuthOtpResendTests {

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
    void resendAfterCooldownIssuesNewChallengeAndInvalidatesOld() throws Exception {
        String email = "resend@example.com";
        String challengeId1 = registerAndGetChallengeId("User", email, "Password123!");
        String code1 = fakeOtpSender.lastCodeFor(email).orElseThrow();
        fakeOtpSender.clear();

        // Force cooldown to appear elapsed.
        jdbcTemplate.update(
                "update otp_codes set resend_available_at = now() - interval '1 second'"
                        + " where destination = ?",
                email);

        MvcResult resendResult =
                mockMvc.perform(
                                post("/api/v1/auth/otp/resend")
                                        .contentType(APPLICATION_JSON)
                                        .content(resendBody(challengeId1)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.success").value(true))
                        .andExpect(jsonPath("$.data.challengeId", startsWith("otp_")))
                        .andExpect(jsonPath("$.data.challengeId", not(challengeId1)))
                        .andExpect(jsonPath("$.data.maskedDestination").value("r***@example.com"))
                        .andExpect(jsonPath("$.data.purpose").value(OtpPurpose.REGISTER.name()))
                        .andExpect(jsonPath("$.data.expiresAt").isString())
                        .andExpect(jsonPath("$.data.resendAvailableAt").isString())
                        .andReturn();

        String challengeId2 =
                JsonPath.read(
                        resendResult.getResponse().getContentAsString(), "$.data.challengeId");
        String code2 = fakeOtpSender.lastCodeFor(email).orElseThrow();

        // New code must differ from old (almost certainly, given SecureRandom).
        // This is a statistical assertion; failure probability ≈ 1 in 10^6.
        assertThat(code2).isNotEqualTo(code1);

        // Old OTP is consumed — using challengeId1 must return OTP_INVALID.
        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId1, code1)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));

        // New OTP works — using challengeId2 must succeed.
        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId2, code2)))
                .andExpect(status().isOk());

        // A rate-limit event was recorded for the resend.
        Integer eventCount =
                jdbcTemplate.queryForObject(
                        "select count(*) from security_rate_limit_events"
                                + " where scope = 'OTP_SEND'",
                        Integer.class);
        // Initial registration + resend = at least 2 events.
        assertThat(eventCount).isGreaterThanOrEqualTo(2);
    }

    // -----------------------------------------------------------------------
    // Error cases
    // -----------------------------------------------------------------------

    @Test
    void resendDuringCooldownReturnsOtpCooldown() throws Exception {
        String email = "cooldown@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");

        // Cooldown is still active (default resend_available_at = now + 1 min).
        mockMvc.perform(
                        post("/api/v1/auth/otp/resend")
                                .contentType(APPLICATION_JSON)
                                .content(resendBody(challengeId)))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("OTP_COOLDOWN"));
    }

    @Test
    void resendAfterConsumedOtpReturnsOtpInvalid() throws Exception {
        String email = "consumed@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");
        String code = fakeOtpSender.lastCodeFor(email).orElseThrow();

        // Verify successfully — OTP is consumed.
        mockMvc.perform(
                        post("/api/v1/auth/otp/verify")
                                .contentType(APPLICATION_JSON)
                                .content(verifyBody(challengeId, code)))
                .andExpect(status().isOk());

        // Try to resend the already-consumed OTP.
        jdbcTemplate.update(
                "update otp_codes set resend_available_at = now() - interval '1 second'"
                        + " where destination = ?",
                email);

        mockMvc.perform(
                        post("/api/v1/auth/otp/resend")
                                .contentType(APPLICATION_JSON)
                                .content(resendBody(challengeId)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));
    }

    @Test
    void resendExceedingRateLimitReturnsRateLimited() throws Exception {
        String email = "ratelimit@example.com";
        String challengeId = registerAndGetChallengeId("User", email, "Password123!");

        // Pre-fill rate-limit events to simulate the limit being reached.
        String subjectKeyHash = sha256Hex(email);
        for (int i = 0; i < 5; i++) {
            jdbcTemplate.update(
                    "insert into security_rate_limit_events"
                            + " (scope, subject_key_hash, succeeded, created_at)"
                            + " values ('OTP_SEND', ?, true, now())",
                    subjectKeyHash);
        }

        jdbcTemplate.update(
                "update otp_codes set resend_available_at = now() - interval '1 second'"
                        + " where destination = ?",
                email);

        mockMvc.perform(
                        post("/api/v1/auth/otp/resend")
                                .contentType(APPLICATION_JSON)
                                .content(resendBody(challengeId)))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("RATE_LIMITED"));
    }

    @Test
    void resendWithUnknownChallengeIdReturnsOtpInvalid() throws Exception {
        mockMvc.perform(
                        post("/api/v1/auth/otp/resend")
                                .contentType(APPLICATION_JSON)
                                .content(resendBody("otp_9999999")))
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

    private static String resendBody(String challengeId) {
        return """
               {"challengeId":"%s"}
               """
                .formatted(challengeId);
    }

    private static String verifyBody(String challengeId, String code) {
        return """
               {"challengeId":"%s","code":"%s"}
               """
                .formatted(challengeId, code);
    }

    /**
     * Computes SHA-256 hex digest of {@code input} — must match {@link OtpIssueHelper#sha256Hex}.
     */
    private static String sha256Hex(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
