package com.viegym.auth.application;

import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;

@Component
public class NimbusGoogleIdentityVerifier implements GoogleIdentityVerifier {

    private static final String GOOGLE_JWKS = "https://www.googleapis.com/oauth2/v3/certs";
    private final JwtDecoder decoder;
    private final String audience;

    public NimbusGoogleIdentityVerifier(@Value("${GOOGLE_CLIENT_ID:}") String audience) {
        this.audience = audience;
        NimbusJwtDecoder jwtDecoder = NimbusJwtDecoder.withJwkSetUri(GOOGLE_JWKS).build();
        OAuth2TokenValidator<Jwt> issuer =
                jwt -> {
                    String value = jwt.getIssuer() == null ? null : jwt.getIssuer().toString();
                    return "accounts.google.com".equals(value)
                                    || "https://accounts.google.com".equals(value)
                            ? OAuth2TokenValidatorResult.success()
                            : OAuth2TokenValidatorResult.failure(
                                    new OAuth2Error("invalid_token", "Invalid issuer", null));
                };
        OAuth2TokenValidator<Jwt> aud =
                jwt ->
                        !audience.isBlank() && jwt.getAudience().contains(audience)
                                ? OAuth2TokenValidatorResult.success()
                                : OAuth2TokenValidatorResult.failure(
                                        new OAuth2Error("invalid_token", "Invalid audience", null));
        jwtDecoder.setJwtValidator(
                new DelegatingOAuth2TokenValidator<>(JwtValidators.createDefault(), issuer, aud));
        this.decoder = jwtDecoder;
    }

    @Override
    public GoogleIdentity verify(String idToken) {
        if (idToken == null || idToken.isBlank() || audience.isBlank()) {
            throw invalid();
        }
        try {
            Jwt jwt = decoder.decode(idToken);
            String subject = jwt.getSubject();
            String email = jwt.getClaimAsString("email");
            Boolean verified = jwt.getClaim("email_verified");
            if (subject == null
                    || subject.isBlank()
                    || email == null
                    || email.isBlank()
                    || !Boolean.TRUE.equals(verified)) {
                throw invalid();
            }
            return new GoogleIdentity(subject, email, jwt.getClaimAsString("name"));
        } catch (JwtException exception) {
            throw invalid();
        }
    }

    private static ApiException invalid() {
        return new ApiException(ApiErrorCode.INVALID_CREDENTIALS, "Invalid Google credential");
    }
}
