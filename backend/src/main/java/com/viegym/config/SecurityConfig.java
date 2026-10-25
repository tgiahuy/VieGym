package com.viegym.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.viegym.admin.auth.web.AdminCookieService;
import com.viegym.admin.auth.web.AdminCsrfFilter;
import com.viegym.common.api.ApiErrorResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.observability.CorrelationId;
import jakarta.servlet.http.Cookie;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.core.convert.converter.Converter;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
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
import org.springframework.security.oauth2.server.resource.web.BearerTokenResolver;
import org.springframework.security.oauth2.server.resource.web.DefaultBearerTokenResolver;
import org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    FilterRegistrationBean<AdminCsrfFilter> disableContainerRegistration(AdminCsrfFilter filter) {
        FilterRegistrationBean<AdminCsrfFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    @Order(1)
    SecurityFilterChain adminSecurityFilterChain(
            HttpSecurity http, ObjectMapper objectMapper, AdminCsrfFilter adminCsrfFilter)
            throws Exception {
        return http.securityMatcher("/api/v1/admin/**")
                .cors(Customizer.withDefaults())
                .csrf(csrf -> csrf.disable())
                .sessionManagement(
                        sessions -> sessions.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(
                        requests ->
                                requests.requestMatchers(
                                                "/api/v1/admin/auth/csrf",
                                                "/api/v1/admin/auth/login",
                                                "/api/v1/admin/auth/refresh",
                                                "/api/v1/admin/auth/logout")
                                        .permitAll()
                                        .anyRequest()
                                        .access(
                                                (authentication, context) -> {
                                                    var current = authentication.get();
                                                    boolean allowed =
                                                            current.isAuthenticated()
                                                                    && current
                                                                            .getAuthorities()
                                                                            .stream()
                                                                            .anyMatch(
                                                                                    authority ->
                                                                                            authority
                                                                                                    .getAuthority()
                                                                                                    .equals(
                                                                                                            "ROLE_ADMIN"))
                                                                    && current
                                                                            .getAuthorities()
                                                                            .stream()
                                                                            .anyMatch(
                                                                                    authority ->
                                                                                            authority
                                                                                                    .getAuthority()
                                                                                                    .equals(
                                                                                                            "AUD_ADMIN_WEB"));
                                                    return new AuthorizationDecision(allowed);
                                                }))
                .oauth2ResourceServer(
                        oauth ->
                                oauth.bearerTokenResolver(adminBearerTokenResolver())
                                        .jwt(
                                                jwt ->
                                                        jwt.jwtAuthenticationConverter(
                                                                jwtAuthorities()))
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
                .addFilterBefore(adminCsrfFilter, BearerTokenAuthenticationFilter.class)
                .build();
    }

    @Bean
    @Order(2)
    SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            ObjectMapper objectMapper,
            @Value("${security.test-endpoints-public:false}") boolean testEndpointsPublic)
            throws Exception {
        return http.cors(Customizer.withDefaults())
                .csrf(csrf -> csrf.disable())
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
                                    .requestMatchers(
                                            org.springframework.http.HttpMethod.PUT,
                                            "/api/v1/media-upload/**")
                                    .permitAll()
                                    .requestMatchers(
                                            org.springframework.http.HttpMethod.GET,
                                            "/api/v1/media-content/**")
                                    .permitAll()
                                    .requestMatchers(
                                            org.springframework.http.HttpMethod.GET,
                                            "/api/v1/exercises/**",
                                            "/api/v1/muscle-groups/**",
                                            "/api/v1/equipment/**")
                                    .permitAll()
                                    .anyRequest()
                                    .hasAuthority("AUD_MOBILE_USER");
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
    CorsConfigurationSource corsConfigurationSource(
            @Value("${CORS_ALLOWED_ORIGINS:}") String allowedOrigins) {
        CorsConfiguration configuration = new CorsConfiguration();
        if (!allowedOrigins.isBlank()) {
            configuration.setAllowedOrigins(
                    Arrays.stream(allowedOrigins.split(","))
                            .map(String::trim)
                            .filter(origin -> !origin.isBlank())
                            .toList());
        }
        configuration.setAllowedMethods(
                List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(
                List.of(
                        "Content-Type",
                        "Authorization",
                        AdminCookieService.CSRF_HEADER,
                        "X-Correlation-ID"));
        configuration.setExposedHeaders(List.of("X-Correlation-ID"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }

    @Bean
    JwtDecoder jwtDecoder(
            @Value("${JWT_SIGNING_KEY:${JWT_SECRET:}}") String secret,
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
        converter.setJwtGrantedAuthoritiesConverter(
                jwt -> {
                    var granted = new ArrayList<>(authorities.convert(jwt));
                    jwt.getAudience().stream()
                            .filter(
                                    audience ->
                                            audience.equals("MOBILE_USER")
                                                    || audience.equals("ADMIN_WEB"))
                            .map(
                                    audience ->
                                            new org.springframework.security.core.authority
                                                    .SimpleGrantedAuthority("AUD_" + audience))
                            .forEach(granted::add);
                    return granted;
                });
        return converter;
    }

    private static BearerTokenResolver adminBearerTokenResolver() {
        DefaultBearerTokenResolver headerResolver = new DefaultBearerTokenResolver();
        return request -> {
            if (request.getCookies() != null) {
                String cookieToken =
                        Arrays.stream(request.getCookies())
                                .filter(
                                        cookie ->
                                                AdminCookieService.ACCESS_COOKIE.equals(
                                                        cookie.getName()))
                                .map(Cookie::getValue)
                                .findFirst()
                                .orElse(null);
                if (cookieToken != null && !cookieToken.isBlank()) {
                    return cookieToken;
                }
            }
            return headerResolver.resolve(request);
        };
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
