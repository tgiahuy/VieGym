package com.viegym.config;

import jakarta.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile({"prod", "production"})
public class ProductionConfigurationValidator {
    private static final Set<String> DEVELOPMENT_VALUES =
            Set.of(
                    "dev-secret-token",
                    "local-development-token",
                    "test-jwt-secret-key-for-dev-and-test",
                    "viegym_dev_password",
                    "minioadmin",
                    "replace_me_before_running");

    private final String jwtSigningKey;
    private final String aiServiceToken;
    private final String dbPassword;

    public ProductionConfigurationValidator(
            @Value("${JWT_SIGNING_KEY:${JWT_SECRET:}}") String jwtSigningKey,
            @Value("${AI_SERVICE_TOKEN:}") String aiServiceToken,
            @Value("${SPRING_DATASOURCE_PASSWORD:${spring.datasource.password:}}") String dbPassword) {
        this.jwtSigningKey = jwtSigningKey;
        this.aiServiceToken = aiServiceToken;
        this.dbPassword = dbPassword;
    }

    @PostConstruct
    void validate() {
        List<String> errors = new ArrayList<>();
        validateSecret("JWT_SIGNING_KEY", jwtSigningKey, 32, errors);
        validateSecret("AI_SERVICE_TOKEN", aiServiceToken, 32, errors);
        validateSecret("SPRING_DATASOURCE_PASSWORD", dbPassword, 8, errors);
        if (!errors.isEmpty()) {
            throw new IllegalStateException(
                    "Unsafe production configuration: " + String.join("; ", errors));
        }
    }

    private static void validateSecret(
            String name, String value, int minimumLength, List<String> errors) {
        if (value == null || value.isBlank()) {
            errors.add(name + " is required");
        } else if (value.length() < minimumLength) {
            errors.add(name + " must contain at least " + minimumLength + " characters");
        } else if (DEVELOPMENT_VALUES.contains(value)) {
            errors.add(name + " must not use a development default");
        }
    }
}
