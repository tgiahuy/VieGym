package com.viegym.auth.api;

/**
 * Session tokens returned after a successful authentication event (OTP verification, login, token
 * refresh).
 *
 * @param accessToken signed JWT access token
 * @param refreshToken opaque refresh token (hex-encoded random bytes)
 * @param tokenType always {@code "Bearer"}
 * @param expiresIn access-token TTL in seconds
 */
public record SessionResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresIn,
        String resetProof) {

    public static SessionResponse session(String accessToken, String refreshToken, long expiresIn) {
        return new SessionResponse(accessToken, refreshToken, "Bearer", expiresIn, null);
    }

    public static SessionResponse resetProof(String resetProof) {
        return new SessionResponse(null, null, null, 0, resetProof);
    }
}
