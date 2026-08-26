package com.viegym.common.error;

import com.viegym.common.api.FieldViolation;
import java.util.List;

public class ApiValidationException extends RuntimeException {

    private final List<FieldViolation> violations;

    public ApiValidationException(List<FieldViolation> violations) {
        super("Request data is invalid");
        this.violations = List.copyOf(violations);
    }

    public List<FieldViolation> violations() {
        return violations;
    }
}
