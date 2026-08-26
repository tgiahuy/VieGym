package com.viegym.health;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.viegym.otp.FakeOtpSender;
import java.time.LocalDate;
import java.time.ZoneId;
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
class HealthProfileIntegrationTests {

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
    @Autowired JdbcTemplate jdbc;
    @Autowired FakeOtpSender otpSender;

    @BeforeEach
    void clean() {
        jdbc.update("delete from nutrition_targets");
        jdbc.update("delete from weight_logs");
        jdbc.update("delete from health_profiles");
        jdbc.update("delete from user_equipment_preferences");
        jdbc.update("delete from user_preferences");
        jdbc.update("delete from password_reset_proofs");
        jdbc.update("delete from security_rate_limit_events");
        jdbc.update("delete from refresh_tokens");
        jdbc.update("delete from otp_codes");
        jdbc.update("delete from user_profiles");
        jdbc.update("delete from users");
        otpSender.clear();
    }

    @Test
    void completeProfileAtomicallyPersistsProfileTargetAndInitialWeight() throws Exception {
        Session session = activate("health-complete@example.com");
        mockMvc.perform(authenticatedCreate(session.token(), completeBody()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.calculationStatus").value("COMPLETE"))
                .andExpect(jsonPath("$.data.profile.calculationVersion").value("health-v1"))
                .andExpect(jsonPath("$.data.metrics.bmi").value(23.59))
                .andExpect(jsonPath("$.data.metrics.bmrKcal").value(1645.13))
                .andExpect(jsonPath("$.data.metrics.tdeeKcal").value(2549.95))
                .andExpect(jsonPath("$.data.nutritionTarget.caloriesKcal").value(2849.95))
                .andExpect(jsonPath("$.data.nutritionTarget.proteinG").value(140.4))
                .andExpect(jsonPath("$.data.nutritionTarget.carbsG").value(393.96))
                .andExpect(jsonPath("$.data.nutritionTarget.fatG").value(79.17))
                .andExpect(jsonPath("$.data.incompleteReason").value((Object) null));

        assertCounts(session.userId(), 1, 1, 1);
        assertThat(
                        jdbc.queryForObject(
                                "select logged_date from weight_logs where user_id = ?",
                                LocalDate.class,
                                session.userId()))
                .isEqualTo(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
    }

    @Test
    void unspecifiedCalculationSexPersistsProfileAndWeightWithoutFakeTarget() throws Exception {
        Session session = activate("health-incomplete@example.com");
        String body =
                completeBody()
                        .replace(
                                "\"calculationSex\":\"MALE\"",
                                "\"calculationSex\":\"UNSPECIFIED\"");
        mockMvc.perform(authenticatedCreate(session.token(), body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.calculationStatus").value("INCOMPLETE"))
                .andExpect(jsonPath("$.data.incompleteReason").value("CALCULATION_SEX_REQUIRED"))
                .andExpect(jsonPath("$.data.metrics.bmi").value(23.59))
                .andExpect(jsonPath("$.data.metrics.bmrKcal").value((Object) null))
                .andExpect(jsonPath("$.data.nutritionTarget").value((Object) null));
        assertCounts(session.userId(), 1, 0, 1);
    }

    @Test
    void validatesRequiredRangesEnumsAndFutureDateWithoutPartialWrites() throws Exception {
        Session session = activate("health-invalid@example.com");
        mockMvc.perform(authenticatedCreate(session.token(), completeBody().replace("172.5", "0")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.errors[0].field").value("heightCm"));
        mockMvc.perform(
                        authenticatedCreate(
                                session.token(), completeBody().replace("MODERATE", "UNKNOWN")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
        mockMvc.perform(
                        authenticatedCreate(
                                session.token(),
                                completeBody().replace("1998-05-20", "2999-01-01")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors[?(@.field == 'dateOfBirth')]").exists());
        assertCounts(session.userId(), 0, 0, 0);
    }

    @Test
    void profileCreationIsOwnerScopedAndCreateOnce() throws Exception {
        Session first = activate("health-owner1@example.com");
        Session second = activate("health-owner2@example.com");
        mockMvc.perform(authenticatedCreate(first.token(), completeBody()))
                .andExpect(status().isCreated());
        mockMvc.perform(authenticatedCreate(first.token(), completeBody()))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INVALID_STATE_TRANSITION"));
        assertCounts(first.userId(), 1, 1, 1);
        assertCounts(second.userId(), 0, 0, 0);
    }

    private void assertCounts(Long userId, int profiles, int targets, int weightLogs) {
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from health_profiles where user_id = ?",
                                Integer.class,
                                userId))
                .isEqualTo(profiles);
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from nutrition_targets where user_id = ?",
                                Integer.class,
                                userId))
                .isEqualTo(targets);
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from weight_logs where user_id = ?",
                                Integer.class,
                                userId))
                .isEqualTo(weightLogs);
    }

    private Session activate(String email) throws Exception {
        MvcResult registered =
                mockMvc.perform(
                                post("/api/v1/auth/register")
                                        .contentType(APPLICATION_JSON)
                                        .content(
                                                """
                                                {"displayName":"Health User","email":"%s","password":"Password123!"}
                                                """
                                                        .formatted(email)))
                        .andExpect(status().isCreated())
                        .andReturn();
        String challenge =
                JsonPath.read(registered.getResponse().getContentAsString(), "$.data.challengeId");
        String code = otpSender.lastCodeFor(email).orElseThrow();
        MvcResult verified =
                mockMvc.perform(
                                post("/api/v1/auth/otp/verify")
                                        .contentType(APPLICATION_JSON)
                                        .content(
                                                """
                                                {"challengeId":"%s","purpose":"REGISTER","code":"%s"}
                                                """
                                                        .formatted(challenge, code)))
                        .andExpect(status().isOk())
                        .andReturn();
        return new Session(
                JsonPath.read(verified.getResponse().getContentAsString(), "$.data.accessToken"),
                jdbc.queryForObject("select id from users where email = ?", Long.class, email));
    }

    private static org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
            authenticatedCreate(String token, String body) {
        return post("/api/v1/health/profile")
                .header("Authorization", "Bearer " + token)
                .contentType(APPLICATION_JSON)
                .content(body);
    }

    private static String completeBody() {
        return """
               {
                 "dateOfBirth":"1998-05-20",
                 "gender":"MALE",
                 "calculationSex":"MALE",
                 "heightCm":172.5,
                 "currentWeightKg":70.2,
                 "activityLevel":"MODERATE",
                 "fitnessGoal":"GAIN_MUSCLE",
                 "trainingExperience":"INTERMEDIATE"
               }
               """;
    }

    private record Session(String token, Long userId) {}
}
