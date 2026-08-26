package com.viegym.token;

import com.viegym.identity.RefreshToken;
import com.viegym.identity.RefreshTokenRepository;
import com.viegym.identity.TokenStatus;
import com.viegym.identity.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.HexFormat;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Issues opaque refresh tokens.
 *
 * <p>A cryptographically random 32-byte token is generated, encoded as hex, and returned to the
 * client. Only its SHA-256 digest is persisted in {@code refresh_tokens.token_hash}, so a database
 * breach does not expose live tokens.
 */
@Component
public class RefreshTokenService {

    private static final int TOKEN_BYTES = 32;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final RefreshTokenRepository refreshTokens;
    private final Clock clock;
    private final Duration ttl;

    RefreshTokenService(
            RefreshTokenRepository refreshTokens,
            Clock clock,
            @Value("${JWT_REFRESH_TTL:P7D}") Duration ttl) {
        this.refreshTokens = refreshTokens;
        this.clock = clock;
        this.ttl = ttl;
    }

    /**
     * Value object returned from {@link #issue}: the plain token for the client + the persisted
     * entity.
     */
    public record Issued(String plainToken, RefreshToken entity) {}

    /**
     * Generates a new refresh token for {@code user}, persists a hashed record, and returns both.
     *
     * @param user the user who will own this refresh token
     * @return an {@link Issued} containing the client-facing plain token and the saved entity
     */
    public Issued issue(User user) {
        return issue(user, null);
    }

    public Issued issue(User user, String deviceInfo) {
        OffsetDateTime now = OffsetDateTime.now(clock);
        byte[] tokenBytes = new byte[TOKEN_BYTES];
        SECURE_RANDOM.nextBytes(tokenBytes);
        String plainToken = HexFormat.of().formatHex(tokenBytes);
        String tokenHash = sha256Hex(plainToken);
        RefreshToken entity =
                refreshTokens.save(
                        new RefreshToken(
                                user,
                                tokenHash,
                                normalizeDeviceInfo(deviceInfo),
                                now.plus(ttl),
                                now));
        return new Issued(plainToken, entity);
    }

    /** SHA-256 hex digest of {@code input} (UTF-8 encoded). */
    public String hash(String input) {
        return sha256Hex(input);
    }

    public void revokeAll(User user, OffsetDateTime now) {
        refreshTokens.findAllByUserIdAndStatus(user.id(), TokenStatus.ACTIVE).stream()
                .forEach(token -> token.revoke(now));
    }

    private static String normalizeDeviceInfo(String deviceInfo) {
        if (deviceInfo == null || deviceInfo.isBlank()) {
            return null;
        }
        String trimmed = deviceInfo.trim();
        return trimmed.substring(0, Math.min(trimmed.length(), 255));
    }

    static String sha256Hex(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }
}
