package com.viegym.auth.application;

import com.viegym.auth.api.SessionResponse;
import com.viegym.identity.User;
import com.viegym.token.JwtAccessTokenService;
import com.viegym.token.RefreshTokenService;
import org.springframework.stereotype.Component;

@Component
public class SessionIssuer {

    private final JwtAccessTokenService jwtTokens;
    private final RefreshTokenService refreshTokens;

    public SessionIssuer(JwtAccessTokenService jwtTokens, RefreshTokenService refreshTokens) {
        this.jwtTokens = jwtTokens;
        this.refreshTokens = refreshTokens;
    }

    public SessionResponse issue(User user, String deviceInfo) {
        RefreshTokenService.Issued refresh = refreshTokens.issue(user, deviceInfo);
        return SessionResponse.session(
                jwtTokens.issue(user), refresh.plainToken(), jwtTokens.ttlSeconds());
    }
}
