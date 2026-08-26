package com.viegym.auth.application;

import com.viegym.common.api.FieldViolation;
import com.viegym.common.error.ApiValidationException;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PasswordPolicy {

    public void validate(String password, String field) {
        List<FieldViolation> violations = new ArrayList<>();
        if (password == null || password.isBlank()) {
            violations.add(new FieldViolation(field, "REQUIRED", field + " is required"));
        } else {
            if (password.length() < 8 || password.length() > 72) {
                violations.add(
                        new FieldViolation(
                                field,
                                "SIZE",
                                field + " must contain between 8 and 72 characters"));
            }
            if (!password.chars().anyMatch(Character::isLetter)
                    || !password.chars().anyMatch(Character::isDigit)) {
                violations.add(
                        new FieldViolation(
                                field, "PATTERN", field + " must contain a letter and a digit"));
            }
        }
        if (!violations.isEmpty()) {
            throw new ApiValidationException(violations);
        }
    }
}
