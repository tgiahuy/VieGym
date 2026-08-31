package com.viegym;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.matchesPattern;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.viegym.common.api.ApiResponse;
import com.viegym.common.api.PageResponse;
import com.viegym.common.api.Pagination;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.AccountStatus;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.OtpPurpose;
import com.viegym.identity.TokenStatus;
import com.viegym.identity.UserRole;
import com.viegym.observability.CorrelationId;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.core.env.Environment;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
@Import(BackendApplicationTests.TestController.class)
class BackendApplicationTests {

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
        registry.add("springdoc.api-docs.enabled", () -> true);
        registry.add("springdoc.swagger-ui.enabled", () -> true);
        registry.add("security.test-endpoints-public", () -> true);
    }

    @Autowired JdbcTemplate jdbcTemplate;
    @Autowired MockMvc mockMvc;
    @Autowired Environment environment;

    @Test
    void connectsToPostgreSqlUsingEnvironmentConfiguration() {
        String database = jdbcTemplate.queryForObject("select current_database()", String.class);
        String user = jdbcTemplate.queryForObject("select current_user", String.class);
        Integer serverVersion =
                jdbcTemplate.queryForObject(
                        "select current_setting('server_version_num')::integer", Integer.class);

        assertThat(database).isEqualTo("viegym_test");
        assertThat(user).isEqualTo("viegym_test");
        assertThat(serverVersion).isBetween(160000, 169999);
    }

    @Test
    void appliesFlywayBaselineOnCleanPostgreSql() {
        Integer applied =
                jdbcTemplate.queryForObject(
                        "select count(*) from flyway_schema_history "
                                + "where version = '0' and success = true",
                        Integer.class);

        assertThat(applied).isEqualTo(1);
    }

    @Test
    void appliesIdentityAndProfileMigrationOnCleanPostgreSql() {
        List<String> tables =
                jdbcTemplate.queryForList(
                        "select table_name from information_schema.tables "
                                + "where table_schema = 'public'",
                        String.class);
        List<String> indexes =
                jdbcTemplate.queryForList(
                        "select indexname from pg_indexes where schemaname = 'public'",
                        String.class);
        List<String> constraints =
                jdbcTemplate.queryForList(
                        "select conname from pg_constraint where conname in "
                                + "('chk_users_auth_provider', 'chk_users_role', 'chk_users_status', "
                                + "'chk_users_local_password', 'chk_users_active_verified', "
                                + "'chk_refresh_tokens_status', 'chk_refresh_tokens_revoked', "
                                + "'chk_otp_codes_purpose', 'chk_otp_codes_attempt_count', "
                                + "'chk_otp_codes_max_attempts', 'chk_security_rate_limit_scope')",
                        String.class);

        assertThat(tables)
                .contains(
                        "users",
                        "refresh_tokens",
                        "otp_codes",
                        "security_rate_limit_events",
                        "user_profiles");
        assertThat(indexes)
                .contains(
                        "uq_users_email_ci",
                        "uq_users_provider_subject",
                        "idx_refresh_tokens_user_status",
                        "idx_otp_destination_purpose",
                        "idx_security_rate_limit_subject");
        assertThat(constraints)
                .contains(
                        "chk_users_auth_provider",
                        "chk_users_role",
                        "chk_users_status",
                        "chk_users_local_password",
                        "chk_users_active_verified",
                        "chk_refresh_tokens_status",
                        "chk_refresh_tokens_revoked",
                        "chk_otp_codes_purpose",
                        "chk_otp_codes_attempt_count",
                        "chk_otp_codes_max_attempts",
                        "chk_security_rate_limit_scope");
    }

    @Test
    void identityEnumsMatchDatabaseConstraints() {
        assertThat(checkConstraintDefinition("chk_users_auth_provider"))
                .contains(enumSqlValues(AuthProvider.class));
        assertThat(checkConstraintDefinition("chk_users_role"))
                .contains(enumSqlValues(UserRole.class));
        assertThat(checkConstraintDefinition("chk_users_status"))
                .contains(enumSqlValues(AccountStatus.class));
        assertThat(checkConstraintDefinition("chk_refresh_tokens_status"))
                .contains(enumSqlValues(TokenStatus.class));
        assertThat(checkConstraintDefinition("chk_otp_codes_purpose"))
                .contains(enumSqlValues(OtpPurpose.class));
    }

    @Test
    void exposesCanonicalSuccessAndPaginationContracts() throws Exception {
        mockMvc.perform(get("/api/v1/test/success"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Operation successful"))
                .andExpect(jsonPath("$.data.value").value("ok"));

        mockMvc.perform(get("/api/v1/test/page"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content", hasSize(1)))
                .andExpect(jsonPath("$.data.page").value(Pagination.DEFAULT_PAGE))
                .andExpect(jsonPath("$.data.size").value(Pagination.DEFAULT_SIZE))
                .andExpect(jsonPath("$.data.totalElements").value(21))
                .andExpect(jsonPath("$.data.totalPages").value(2))
                .andExpect(jsonPath("$.data.hasNext").value(true));

        assertThat(Pagination.MAX_SIZE).isEqualTo(100);
    }

    @Test
    void mapsValidationErrorsToCanonicalEnvelope() throws Exception {
        String correlationId = UUID.randomUUID().toString();

        mockMvc.perform(
                        post("/api/v1/test/validate")
                                .header(CorrelationId.HEADER_NAME, correlationId)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("{\"heightCm\":0}"))
                .andExpect(status().isBadRequest())
                .andExpect(header().string(CorrelationId.HEADER_NAME, correlationId))
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.message").value("Request data is invalid"))
                .andExpect(jsonPath("$.data").value(nullValue()))
                .andExpect(jsonPath("$.errors", hasSize(1)))
                .andExpect(jsonPath("$.errors[0].field").value("heightCm"))
                .andExpect(jsonPath("$.errors[0].code").value("POSITIVE"))
                .andExpect(jsonPath("$.correlationId").value(correlationId))
                .andExpect(jsonPath("$.timestamp").isString());
    }

    @Test
    void mapsBusinessExceptionsAndGeneratesCorrelationId() throws Exception {
        mockMvc.perform(get("/api/v1/test/api-error"))
                .andExpect(status().isNotFound())
                .andExpect(
                        header().string(
                                        CorrelationId.HEADER_NAME,
                                        matchesPattern(
                                                "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")))
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"))
                .andExpect(jsonPath("$.errors", hasSize(0)));
    }

    @Test
    void exposesHealthGroupsWithDatabaseOnlyInReadiness() throws Exception {
        assertThat(environment.getProperty("management.endpoint.health.group.liveness.include"))
                .isEqualTo("livenessState,ping");
        assertThat(environment.getProperty("management.endpoint.health.group.readiness.include"))
                .isEqualTo("readinessState,db");

        mockMvc.perform(get("/actuator/health/liveness"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
        mockMvc.perform(get("/actuator/health/readiness"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
    }

    @Test
    void exposesVersionedOpenApiAndSwaggerUi() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.openapi").value(matchesPattern("3\\.[01]\\..+")))
                .andExpect(jsonPath("$.info.title").value("VieGym API"))
                .andExpect(jsonPath("$.info.version").value("v1"))
                .andExpect(jsonPath("$.servers[0].url").value("http://localhost:8080/api/v1"))
                .andExpect(jsonPath("$.components.securitySchemes.bearerAuth.type").value("http"))
                .andExpect(
                        jsonPath("$.components.securitySchemes.bearerAuth.scheme").value("bearer"));

        mockMvc.perform(get("/swagger-ui.html"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/swagger-ui/index.html"));
    }

    private String checkConstraintDefinition(String name) {
        return jdbcTemplate.queryForObject(
                "select pg_get_constraintdef(oid) from pg_constraint where conname = ?",
                String.class,
                name);
    }

    private <T extends Enum<T>> String enumSqlValues(Class<T> enumType) {
        return Arrays.stream(enumType.getEnumConstants())
                .map(value -> "'" + value.name() + "'::character varying")
                .toList()
                .toString();
    }

    @RestController
    @RequestMapping("/api/v1/test")
    static class TestController {

        @GetMapping("/success")
        ApiResponse<Map<String, String>> success() {
            return ApiResponse.success(Map.of("value", "ok"));
        }

        @GetMapping("/page")
        ApiResponse<PageResponse<String>> page() {
            return ApiResponse.success(
                    new PageResponse<>(
                            List.of("first"),
                            Pagination.DEFAULT_PAGE,
                            Pagination.DEFAULT_SIZE,
                            21,
                            2,
                            true));
        }

        @PostMapping("/validate")
        ApiResponse<Void> validate(@Valid @RequestBody ValidationRequest request) {
            return ApiResponse.success(null);
        }

        @GetMapping("/api-error")
        void apiError() {
            throw new ApiException(ApiErrorCode.RESOURCE_NOT_FOUND, "Resource not found");
        }
    }

    record ValidationRequest(@Positive(message = "heightCm must be greater than 0") int heightCm) {}
}
