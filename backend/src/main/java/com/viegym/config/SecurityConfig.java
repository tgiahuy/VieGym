package com.viegym.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.common.api.ApiErrorResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.observability.CorrelationId;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    private static final String DEFAULT_SECRET = "test-jwt-secret-key-for-dev-and-test";

    @Bean
    SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            ObjectMapper objectMapper,
            @Value("${security.test-endpoints-public:false}") boolean testEndpointsPublic)
            throws Exception {
        return http.csrf(csrf -> csrf.disable())
                .sessionManagement(
                        sessions -> sessions.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(
                        requests -> {
                            if (testEndpointsPublic) {
                                requests.requestMatchers("/api/v1/test/**").permitAll();
                            }
                            requests.requestMatchers(
                                            "/actuator/health/**",
                                            "/v3/api-docs/**",
                                            "/swagger-ui/**",
                                            "/swagger-ui.html",
                                            "/api/v1/auth/register",
                                            "/api/v1/auth/login",
                                            "/api/v1/auth/google",
                                            "/api/v1/auth/facebook",
                                            "/api/v1/auth/refresh",
                                            "/api/v1/auth/otp/**",
                                            "/api/v1/auth/password/forgot",
                                            "/api/v1/auth/password/reset")
                                    .permitAll()
                                    .requestMatchers("/api/v1/admin/**")
                                    .hasRole("ADMIN")
                                    .anyRequest()
                                    .authenticated();
                        })
                .oauth2ResourceServer(
                        oauth ->
                                oauth.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthorities()))
                                        .authenticationEntryPoint(
                                                (request, response, exception) ->
                                                        writeError(
                                                                response,
                                                                objectMapper,
                                                                ApiErrorCode.UNAUTHENTICATED,
                                                                "Authentication is required")))
                .exceptionHandling(
                        errors ->
                                errors.accessDeniedHandler(
                                        (request, response, exception) ->
                                                writeError(
                                                        response,
                                                        objectMapper,
                                                        ApiErrorCode.ACCESS_DENIED,
                                                        "Access is denied")))
                .build();
    }

    @Bean
    JwtDecoder jwtDecoder(
            @Value("${JWT_SIGNING_KEY:${JWT_SECRET:" + DEFAULT_SECRET + "}}") String secret,
            @Value("${JWT_ISSUER:viegym-backend}") String issuer,
            @Value("${JWT_AUDIENCE:viegym-api}") String audience) {
        byte[] keyBytes = sha256(secret);
        SecretKey key = new SecretKeySpec(keyBytes, "HmacSHA256");
        NimbusJwtDecoder decoder = NimbusJwtDecoder.withSecretKey(key).build();
        OAuth2TokenValidator<Jwt> audienceValidator =
                jwt ->
                        jwt.getAudience().contains(audience)
                                ? OAuth2TokenValidatorResult.success()
                                : OAuth2TokenValidatorResult.failure(
                                        new OAuth2Error("invalid_token", "Invalid audience", null));
        decoder.setJwtValidator(
                new DelegatingOAuth2TokenValidator<>(
                        JwtValidators.createDefaultWithIssuer(issuer), audienceValidator));
        return decoder;
    }

    private static Converter<Jwt, ? extends AbstractAuthenticationToken> jwtAuthorities() {
        JwtGrantedAuthoritiesConverter authorities = new JwtGrantedAuthoritiesConverter();
        authorities.setAuthoritiesClaimName("role");
        authorities.setAuthorityPrefix("ROLE_");
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(authorities);
        return converter;
    }

    private static byte[] sha256(String value) {
        try {
            return MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 not available", exception);
        }
    }

    private static void writeError(
            jakarta.servlet.http.HttpServletResponse response,
            ObjectMapper objectMapper,
            ApiErrorCode code,
            String message)
            throws java.io.IOException {
        response.setStatus(code.httpStatus().value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        objectMapper.writeValue(
                response.getWriter(),
                ApiErrorResponse.of(
                        code.name(), message, List.of(), CorrelationId.currentOrCreate()));
    }
}
