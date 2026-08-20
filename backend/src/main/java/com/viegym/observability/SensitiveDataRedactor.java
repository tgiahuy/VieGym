package com.viegym.observability;

import java.util.regex.Pattern;

public final class SensitiveDataRedactor {

    public static final String REDACTED = "[REDACTED]";

    private static final Pattern BEARER_TOKEN =
            Pattern.compile("(?i)\\bBearer\\s+[A-Za-z0-9._~+/=-]+");
    private static final Pattern SENSITIVE_FIELD =
            Pattern.compile(
                    "(?i)(password|accessToken|refreshToken|token|otp|secret|api[-_]?key|authorization)"
                            + "(\\s*[=:]\\s*\\\"?)([^\\\"\\s,}]+)");

    private SensitiveDataRedactor() {}

    public static String redact(String value) {
        if (value == null) {
            return null;
        }
        String withoutBearer = BEARER_TOKEN.matcher(value).replaceAll("Bearer " + REDACTED);
        return SENSITIVE_FIELD.matcher(withoutBearer).replaceAll("$1$2" + REDACTED);
    }
}
