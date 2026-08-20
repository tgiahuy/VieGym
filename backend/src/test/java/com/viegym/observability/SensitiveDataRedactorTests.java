package com.viegym.observability;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SensitiveDataRedactorTests {

    @Test
    void redactsCredentialsAndSecurityTokens() {
        String input =
                "password=hunter2 otp=123456 accessToken=abc.def refreshToken=refresh-value "
                        + "api_key=provider-key Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.payload.sig";

        String redacted = SensitiveDataRedactor.redact(input);

        assertThat(redacted)
                .doesNotContain(
                        "hunter2",
                        "123456",
                        "abc.def",
                        "refresh-value",
                        "provider-key",
                        "eyJhbGciOiJIUzI1NiJ9")
                .contains(SensitiveDataRedactor.REDACTED);
    }

    @Test
    void leavesNonSensitiveOperationalMetadataReadable() {
        String input = "event=recommendation.apply result=SUCCEEDED durationMs=84";

        assertThat(SensitiveDataRedactor.redact(input)).isEqualTo(input);
    }
}
