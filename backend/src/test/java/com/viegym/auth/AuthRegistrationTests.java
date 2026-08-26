package com.viegym.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.viegym.identity.AccountStatus;
import com.viegym.identity.AuthProvider;
import com.viegym.identity.OtpPurpose;
import com.viegym.identity.UserRole;
import com.viegym.otp.FakeOtpSender;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
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
class AuthRegistrationTests {

    private static final String REGISTER_SUCCESS_MESSAGE =
            "Verification instructions have been sent if the address is eligible";

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
    @Autowired PasswordEncoder passwordEncoder;
    @Autowired FakeOtpSender fakeOtpSender;

    @BeforeEach
    void cleanDatabase() {
        jdbcTemplate.update("delete from security_rate_limit_events");
        jdbcTemplate.update("delete from otp_codes");
        jdbcTemplate.update("delete from user_profiles");
        jdbcTemplate.update("delete from users");
        fakeOtpSender.clear();
    }

    @Test
    void registersPendingLocalUserWithNormalizedEmailAndBcryptHash() throws Exception {
        String password = "StrongPassword123!";

        MvcResult result =
                mockMvc.perform(
                                post("/api/v1/auth/register")
                                        .contentType(MediaType.APPLICATION_JSON)
                                        .content(
                                                """
                                                {
                                                  "displayName": "  Nguyễn Minh An  ",
                                                  "email": "  An@Example.COM  ",
                                                  "password": "StrongPassword123!"
                                                }
                                                """))
                        .andExpect(status().isCreated())
                        .andExpect(jsonPath("$.success").value(true))
                        .andExpect(jsonPath("$.message").value(REGISTER_SUCCESS_MESSAGE))
                        .andExpect(jsonPath("$.data.challengeId", startsWith("otp_")))
                        .andExpect(jsonPath("$.data.maskedDestination").value("a***@example.com"))
                        .andExpect(jsonPath("$.data.purpose").value(OtpPurpose.REGISTER.name()))
                        .andExpect(jsonPath("$.data.expiresAt").isString())
                        .andExpect(jsonPath("$.data.resendAvailableAt").isString())
                        .andExpect(jsonPath("$.data.accessToken").doesNotExist())
                        .andExpect(jsonPath("$.data.refreshToken").doesNotExist())
                        .andReturn();

        String responseBody = result.getResponse().getContentAsString();
        assertThat(responseBody)
                .doesNotContain(password, "passwordHash", "accessToken", "refreshToken");

        UserRow user =
                jdbcTemplate.queryForObject(
                        "select id, email, password_hash, auth_provider, role, status, "
                                + "email_verified_at is null as email_unverified from users "
                                + "where email = 'an@example.com'",
                        (rs, rowNum) ->
                                new UserRow(
                                        rs.getLong("id"),
                                        rs.getString("email"),
                                        rs.getString("password_hash"),
                                        rs.getString("auth_provider"),
                                        rs.getString("role"),
                                        rs.getString("status"),
                                        rs.getBoolean("email_unverified")));

        assertThat(user.email()).isEqualTo("an@example.com");
        assertThat(user.authProvider()).isEqualTo(AuthProvider.LOCAL.name());
        assertThat(user.role()).isEqualTo(UserRole.USER.name());
        assertThat(user.status()).isEqualTo(AccountStatus.PENDING.name());
        assertThat(user.emailUnverified()).isTrue();
        assertThat(user.passwordHash()).isNotEqualTo(password);
        assertThat(passwordEncoder.matches(password, user.passwordHash())).isTrue();

        String displayName =
                jdbcTemplate.queryForObject(
                        "select display_name from user_profiles where user_id = ?",
                        String.class,
                        user.id());
        assertThat(displayName).isEqualTo("Nguyễn Minh An");

        // OTP record persisted in otp_codes -----------------------------------
        OtpRow otp =
                jdbcTemplate.queryForObject(
                        "select destination, purpose, code_hash, attempt_count, max_attempts,"
                                + " consumed_at is null as not_consumed"
                                + " from otp_codes where user_id = ?",
                        (rs, rowNum) ->
                                new OtpRow(
                                        rs.getString("destination"),
                                        rs.getString("purpose"),
                                        rs.getString("code_hash"),
                                        rs.getInt("attempt_count"),
                                        rs.getInt("max_attempts"),
                                        rs.getBoolean("not_consumed")),
                        user.id());

        assertThat(otp.destination()).isEqualTo("an@example.com");
        assertThat(otp.purpose()).isEqualTo(OtpPurpose.REGISTER.name());
        assertThat(otp.attemptCount()).isZero();
        assertThat(otp.maxAttempts()).isGreaterThan(0);
        assertThat(otp.notConsumed()).isTrue();

        // FakeOtpSender captured a valid 6-digit code -------------------------
        String sentCode =
                fakeOtpSender
                        .lastCodeFor("an@example.com")
                        .orElseThrow(() -> new AssertionError("FakeOtpSender captured no code"));
        assertThat(sentCode).matches("\\d{6}");
        assertThat(passwordEncoder.matches(sentCode, otp.codeHash())).isTrue();
    }

    private record OtpRow(
            String destination,
            String purpose,
            String codeHash,
            int attemptCount,
            int maxAttempts,
            boolean notConsumed) {}

    @Test
    void rejectsDuplicateNormalizedEmail() throws Exception {
        register("First User", "Test@Example.com", "StrongPassword123!")
                .andExpect(status().isCreated());

        register("Second User", " test@example.com ", "AnotherPassword123!")
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("EMAIL_ALREADY_EXISTS"))
                .andExpect(jsonPath("$.message").value(REGISTER_SUCCESS_MESSAGE))
                .andExpect(jsonPath("$.data").value(nullValue()))
                .andExpect(jsonPath("$.errors", hasSize(0)));

        Integer users = jdbcTemplate.queryForObject("select count(*) from users", Integer.class);
        assertThat(users).isEqualTo(1);
    }

    @Test
    void rejectsInvalidRegistrationInput() throws Exception {
        String longPassword = "a".repeat(73) + "1";

        register("", "not-an-email", "short")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.message").value("Request data is invalid"))
                .andExpect(jsonPath("$.errors", hasSize(4)))
                .andExpect(jsonPath("$.errors[?(@.field == 'displayName')]", not(hasSize(0))))
                .andExpect(jsonPath("$.errors[?(@.field == 'email')]", not(hasSize(0))))
                .andExpect(jsonPath("$.errors[?(@.field == 'password')]", not(hasSize(0))));

        register("Valid User", "valid@example.com", longPassword)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.errors[?(@.field == 'password')]", not(hasSize(0))));
    }

    private org.springframework.test.web.servlet.ResultActions register(
            String displayName, String email, String password) throws Exception {
        String body =
                """
                {
                  "displayName": "%s",
                  "email": "%s",
                  "password": "%s"
                }
                """
                        .formatted(displayName, email, password);
        return mockMvc.perform(
                post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body));
    }

    private record UserRow(
            long id,
            String email,
            String passwordHash,
            String authProvider,
            String role,
            String status,
            boolean emailUnverified) {}
}
