package com.viegym.token;

import com.viegym.identity.User;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Clock;
import java.time.Duration;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Issues signed JWT access tokens.
 *
 * <p>The token carries a minimal set of claims needed by resource servers: {@code sub} (user ID),
 * {@code email} and {@code role}. The signing key is loaded from {@code JWT_SECRET} (base64-encoded
 * ≥ 32-byte key); a safe default is provided for local development and tests.
 */
@Component
public class JwtAccessTokenService {

    private static final String DEFAULT_SECRET = "test-jwt-secret-key-for-dev-and-test";

    private final SecretKey secretKey;
    private final Duration ttl;
    private final Clock clock;
    private final String issuer;
    private final String audience;

    JwtAccessTokenService(
            Clock clock,
            @Value("${JWT_SIGNING_KEY:${JWT_SECRET:" + DEFAULT_SECRET + "}}") String secret,
            @Value("${JWT_ACCESS_TTL:PT15M}") Duration ttl,
            @Value("${JWT_ISSUER:viegym-backend}") String issuer,
            @Value("${JWT_AUDIENCE:viegym-api}") String audience) {
        this.clock = clock;
        this.secretKey = Keys.hmacShaKeyFor(sha256(secret));
        this.ttl = ttl;
        this.issuer = issuer;
        this.audience = audience;
    }

    /**
     * Issues a signed JWT for the given user.
     *
     * @param user the authenticated / newly-activated user
     * @return compact JWT string
     */
    public String issue(User user) {
        Date now = Date.from(clock.instant());
        Date expiry = Date.from(clock.instant().plus(ttl));
        return Jwts.builder()
                .issuer(issuer)
                .audience()
                .add(audience)
                .and()
                .subject(String.valueOf(user.id()))
                .claim("email", user.email())
                .claim("role", user.role().name())
                .issuedAt(now)
                .expiration(expiry)
                .signWith(secretKey)
                .compact();
    }

    /** Access-token TTL in seconds (returned to clients as {@code expiresIn}). */
    public long ttlSeconds() {
        return ttl.getSeconds();
    }

    private static byte[] sha256(String value) {
        try {
            return MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 not available", exception);
        }
    }
}
