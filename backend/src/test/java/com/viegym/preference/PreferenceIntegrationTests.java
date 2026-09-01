package com.viegym.preference;

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
class PreferenceIntegrationTests {

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
    void replacesAndReadsWholePreferenceDocumentForAuthenticatedOwner() throws Exception {
        Session owner = activate("preference@example.com");
        String body =
                """
                {
                  "dislikedFoods":["mướp đắng"],
                  "allergies":["PEANUT"],
                  "dietaryConstraints":["NO_PORK"],
                  "mealPreferences":{"preferredCuisine":["VIETNAMESE"]},
                  "trainingPreferences":{"preferredProgramType":"FULL_BODY","daysPerWeek":3},
                  "preferredTrainingTime":"18:30:00"
                }
                """;
        mockMvc.perform(authPut("/api/v1/preferences", owner.token(), body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.dislikedFoods[0]").value("mướp đắng"))
                .andExpect(jsonPath("$.data.trainingPreferences.daysPerWeek").value(3))
                .andExpect(jsonPath("$.data.preferredTrainingTime").value("18:30:00"));
        mockMvc.perform(authGet("/api/v1/preferences", owner.token()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.allergies[0]").value("PEANUT"));
    }

    @Test
    void equipmentCatalogAndSelectionAreOwnedAndReplaceBased() throws Exception {
        Session first = activate("equipment1@example.com");
        Session second = activate("equipment2@example.com");

        mockMvc.perform(authGet("/api/v1/preferences/equipment", first.token()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.selectedEquipmentIds").isEmpty())
                .andExpect(jsonPath("$.data.equipment.length()").value(11))
                .andExpect(jsonPath("$.data.equipmentOnboardingCompletedAt").value((Object) null));

        mockMvc.perform(
                        authPut(
                                "/api/v1/preferences/equipment",
                                first.token(),
                                "{\"equipmentIds\":[1,2]}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.selectedEquipmentIds[0]").value(1))
                .andExpect(jsonPath("$.data.selectedEquipmentIds[1]").value(2))
                .andExpect(jsonPath("$.data.equipment[0].selected").value(true));
        mockMvc.perform(authGet("/api/v1/preferences/equipment", second.token()))
                .andExpect(jsonPath("$.data.selectedEquipmentIds").isEmpty());
    }

    @Test
    void emptyEquipmentSelectionStillCompletesOnboarding() throws Exception {
        Session session = activate("empty-equipment@example.com");
        mockMvc.perform(
                        authPut(
                                "/api/v1/preferences/equipment",
                                session.token(),
                                "{\"equipmentIds\":[]}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.selectedEquipmentIds").isEmpty())
                .andExpect(jsonPath("$.data.equipmentOnboardingCompletedAt").isString());

        mockMvc.perform(authGet("/api/v1/users/me", session.token()))
                .andExpect(jsonPath("$.data.onboarding.equipmentCompleted").value(true));
    }

    @Test
    void rejectsDuplicateOrUnknownEquipmentWithoutChangingExistingSelection() throws Exception {
        Session session = activate("invalid-equipment@example.com");
        mockMvc.perform(
                        authPut(
                                "/api/v1/preferences/equipment",
                                session.token(),
                                "{\"equipmentIds\":[1]}"))
                .andExpect(status().isOk());
        mockMvc.perform(
                        authPut(
                                "/api/v1/preferences/equipment",
                                session.token(),
                                "{\"equipmentIds\":[1,1]}"))
                .andExpect(status().isBadRequest());
        mockMvc.perform(
                        authPut(
                                "/api/v1/preferences/equipment",
                                session.token(),
                                "{\"equipmentIds\":[999999]}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors[0].field").value("equipmentIds"));
        assertThat(
                        jdbc.queryForObject(
                                "select count(*) from user_equipment_preferences where user_id = ?",
                                Integer.class,
                                session.userId()))
                .isEqualTo(1);
    }

    private Session activate(String email) throws Exception {
        MvcResult registered =
                mockMvc.perform(
                                post("/api/v1/auth/register")
                                        .contentType(APPLICATION_JSON)
                                        .content(
                                                """
                                                {"displayName":"Preference User","email":"%s","password":"Password123!"}
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
            authGet(String path, String token) {
        return get(path).header("Authorization", "Bearer " + token);
    }

    private static org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
            authPut(String path, String token, String body) {
        return put(path)
                .header("Authorization", "Bearer " + token)
                .contentType(APPLICATION_JSON)
                .content(body);
    }

    private record Session(String token, Long userId) {}
}
