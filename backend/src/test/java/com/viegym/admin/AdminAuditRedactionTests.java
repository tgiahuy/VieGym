package com.viegym.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.admin.audit.application.AdminAuditService;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.jdbc.core.JdbcTemplate;

class AdminAuditRedactionTests {
    @Test
    void redactsSecretsAtEveryObjectLevel() {
        JdbcTemplate jdbc = mock(JdbcTemplate.class);
        AdminAuditService service = new AdminAuditService(jdbc, new ObjectMapper());

        service.record(
                1L,
                "ADMIN",
                "UPDATE",
                "EXERCISE",
                3L,
                "SUCCESS",
                Map.of(
                        "name", "Bench press",
                        "password", "never-store",
                        "nested", Map.of("apiKey", "secret-key", "safe", "yes")));

        ArgumentCaptor<Object> metadata = ArgumentCaptor.forClass(Object.class);
        verify(jdbc)
                .update(
                        anyString(),
                        eq(1L),
                        eq("ADMIN"),
                        eq("UPDATE"),
                        eq("EXERCISE"),
                        eq("3"),
                        eq("SUCCESS"),
                        anyString(),
                        metadata.capture());
        String json = String.valueOf(metadata.getValue());
        assertThat(json).contains("Bench press", "[REDACTED]", "yes");
        assertThat(json).doesNotContain("never-store", "secret-key");
    }
}
