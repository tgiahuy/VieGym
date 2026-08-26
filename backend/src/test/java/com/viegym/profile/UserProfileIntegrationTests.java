package com.viegym.profile;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
class UserProfileIntegrationTests {

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
        jdbcTemplate.update("delete from nutrition_targets");
        jdbcTemplate.update("delete from weight_logs");
        jdbcTemplate.update("delete from health_profiles");
        jdbcTemplate.update("delete from user_equipment_preferences");
        jdbcTemplate.update("delete from user_preferences");
        jdbcTemplate.update("delete from password_reset_proofs");
        jdbcTemplate.update("delete from security_rate_limit_events");
        jdbcTemplate.update("delete from refresh_tokens");
        jdbcTemplate.update("delete from otp_codes");
        jdbcTemplate.update("delete from user_profiles");
        jdbcTemplate.update("delete from users");
        fakeOtpSender.clear();
    }

    @Test
    void getRequiresJwtAndReturnsCanonicalProfileOwnedBySubject() throws Exception {
        Session first = activate("first@example.com", "First User");
        Session second = activate("second@example.com", "Second User");

        mockMvc.perform(get("/api/v1/users/me")).andExpect(status().isUnauthorized());
        mockMvc.perform(authenticatedGet(first.token()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(first.userId()))
                .andExpect(jsonPath("$.data.email").value("first@example.com"))
                .andExpect(jsonPath("$.data.displayName").value("First User"))
                .andExpect(jsonPath("$.data.avatar").value((Object) null))
                .andExpect(jsonPath("$.data.timezone").value("Asia/Ho_Chi_Minh"))
                .andExpect(jsonPath("$.data.locale").value("vi-VN"))
                .andExpect(jsonPath("$.data.role").value("USER"))
                .andExpect(jsonPath("$.data.authProvider").value("LOCAL"))
                .andExpect(jsonPath("$.data.onboarding.healthProfileCompleted").value(false))
                .andExpect(jsonPath("$.data.onboarding.equipmentCompleted").value(false));
        assertThat(first.userId()).isNotEqualTo(second.userId());
    }

    @Test
    void putUpdatesOnlyAuthenticatedUsersProfile() throws Exception {
        Session first = activate("owner@example.com", "Owner");
        Session second = activate("other@example.com", "Other");
        mockMvc.perform(
                        put("/api/v1/users/me")
                                .header("Authorization", "Bearer " + first.token())
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                        {"displayName":"Updated Owner","avatarMediaId":null,
                                         "timezone":"Europe/Paris","locale":"fr-FR"}
                                        """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.displayName").value("Updated Owner"))
                .andExpect(jsonPath("$.data.timezone").value("Europe/Paris"))
                .andExpect(jsonPath("$.data.locale").value("fr-FR"));

        mockMvc.perform(authenticatedGet(second.token()))
                .andExpect(jsonPath("$.data.displayName").value("Other"));
    }

    @Test
    void putRejectsMissingOversizedInvalidUnsupportedAndUnknownFields() throws Exception {
        Session session = activate("validation@example.com", "Original");
        String token = session.token();

        assertInvalid(token, "{\"timezone\":\"UTC\",\"locale\":\"en-US\"}", "displayName");
        assertInvalid(
                token,
                "{\"displayName\":\"%s\",\"timezone\":\"UTC\",\"locale\":\"en-US\"}"
                        .formatted("x".repeat(121)),
                "displayName");
        assertInvalid(
                token,
                "{\"displayName\":\"Valid\",\"timezone\":\"Mars/Olympus\",\"locale\":\"en-US\"}",
                "timezone");
        assertInvalid(
                token,
                "{\"displayName\":\"Valid\",\"timezone\":\"UTC\",\"locale\":\"bad_locale\"}",
                "locale");
        assertInvalid(
                token,
                "{\"displayName\":\"Valid\",\"avatarMediaId\":91,\"timezone\":\"UTC\",\"locale\":\"en-US\"}",
                "avatarMediaId");
        assertInvalid(
                token,
                "{\"displayName\":\"Valid\",\"timezone\":\"UTC\",\"locale\":\"en-US\",\"email\":\"attacker@example.com\"}",
                "email");

        mockMvc.perform(authenticatedGet(token))
                .andExpect(jsonPath("$.data.displayName").value("Original"));
    }

    @Test
    void onboardingFlagsComeFromRequiredPersistenceFacts() throws Exception {
        Session session = activate("onboarding@example.com", "Onboarding");
        jdbcTemplate.update(
                "insert into user_preferences(user_id, equipment_onboarding_completed_at) values (?, now())",
                session.userId());
        jdbcTemplate.update(
                """
                insert into health_profiles(
                  user_id,date_of_birth,gender,calculation_sex,height_cm,current_weight_kg,
                  activity_level,fitness_goal,training_experience,bmi,calculation_version,calculated_at)
                values (?,date '1990-01-01','UNSPECIFIED','UNSPECIFIED',170,70,
                  'MODERATE','MAINTAIN_WEIGHT','BEGINNER',24.22,'test',now())
                """,
                session.userId());

        mockMvc.perform(authenticatedGet(session.token()))
                .andExpect(jsonPath("$.data.onboarding.healthProfileCompleted").value(true))
                .andExpect(jsonPath("$.data.onboarding.equipmentCompleted").value(true));
    }

    private void assertInvalid(String token, String body, String field) throws Exception {
        mockMvc.perform(
                        put("/api/v1/users/me")
                                .header("Authorization", "Bearer " + token)
                                .contentType(APPLICATION_JSON)
                                .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.errors[?(@.field == '%s')]".formatted(field)).exists());
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
            authenticatedGet(String token) {
        return get("/api/v1/users/me").header("Authorization", "Bearer " + token);
    }

    private Session activate(String email, String displayName) throws Exception {
        MvcResult registered =
                mockMvc.perform(
                                post("/api/v1/auth/register")
                                        .contentType(APPLICATION_JSON)
                                        .content(
                                                """
                                                {"displayName":"%s","email":"%s","password":"Password123!"}
                                                """
                                                        .formatted(displayName, email)))
                        .andExpect(status().isCreated())
                        .andReturn();
        String challenge =
                JsonPath.read(registered.getResponse().getContentAsString(), "$.data.challengeId");
        String code = fakeOtpSender.lastCodeFor(email).orElseThrow();
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
        String token =
                JsonPath.read(verified.getResponse().getContentAsString(), "$.data.accessToken");
        Long userId =
                jdbcTemplate.queryForObject(
                        "select id from users where email = ?", Long.class, email);
        return new Session(token, userId);
    }

    private record Session(String token, Long userId) {}
}
