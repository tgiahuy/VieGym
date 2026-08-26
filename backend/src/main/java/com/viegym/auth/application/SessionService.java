package com.viegym.auth.application;

import com.viegym.auth.api.RefreshRequest;
import com.viegym.auth.api.SessionResponse;
import com.viegym.common.error.ApiErrorCode;
import com.viegym.common.error.ApiException;
import com.viegym.identity.RefreshToken;
import com.viegym.identity.RefreshTokenRepository;
import com.viegym.identity.TokenStatus;
import com.viegym.token.JwtAccessTokenService;
import com.viegym.token.RefreshTokenService;
import java.time.Clock;
import java.time.OffsetDateTime;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SessionService {

    private final RefreshTokenRepository refreshTokens;
    private final RefreshTokenService tokenService;
    private final JwtAccessTokenService jwtTokens;
    private final Clock clock;

    public SessionService(
            RefreshTokenRepository refreshTokens,
            RefreshTokenService tokenService,
            JwtAccessTokenService jwtTokens,
            Clock clock) {
        this.refreshTokens = refreshTokens;
        this.tokenService = tokenService;
        this.jwtTokens = jwtTokens;
        this.clock = clock;
    }

    @Transactional(noRollbackFor = ApiException.class)
    public SessionResponse refresh(RefreshRequest request) {
        String plain = request == null ? null : request.refreshToken();
        if (plain == null || plain.isBlank()) {
            throw new ApiException(ApiErrorCode.UNAUTHENTICATED, "Refresh token is required");
        }
        OffsetDateTime now = OffsetDateTime.now(clock);
        RefreshToken current =
                refreshTokens
                        .findByTokenHashForUpdate(tokenService.hash(plain))
                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                ApiErrorCode.UNAUTHENTICATED,
                                                "Invalid refresh token"));

        if (current.status() == TokenStatus.REVOKED) {
            revokeReplacementChain(current, now);
            throw new ApiException(ApiErrorCode.TOKEN_REVOKED, "Refresh token was revoked");
        }
        if (current.status() == TokenStatus.EXPIRED || !now.isBefore(current.expiresAt())) {
            current.expire();
            throw new ApiException(ApiErrorCode.TOKEN_EXPIRED, "Refresh token has expired");
        }
        LoginService.ensureActive(current.user().status());

        RefreshTokenService.Issued replacement =
                tokenService.issue(current.user(), request.deviceInfo());
        current.rotateTo(replacement.entity(), now);
        return SessionResponse.session(
                jwtTokens.issue(current.user()), replacement.plainToken(), jwtTokens.ttlSeconds());
    }

    @Transactional
    public void logout(String plainToken, Long authenticatedUserId) {
        if (plainToken == null || plainToken.isBlank()) {
            return;
        }
        refreshTokens
                .findByTokenHashForUpdate(tokenService.hash(plainToken))
                .filter(token -> token.user().id().equals(authenticatedUserId))
                .ifPresent(token -> token.revoke(OffsetDateTime.now(clock)));
    }

    private void revokeReplacementChain(RefreshToken token, OffsetDateTime now) {
        Long nextId = token.replacedByTokenId();
        while (nextId != null) {
            RefreshToken next = refreshTokens.findById(nextId).orElse(null);
            if (next == null) {
                return;
            }
            next.revoke(now);
            nextId = next.replacedByTokenId();
        }
    }
}
