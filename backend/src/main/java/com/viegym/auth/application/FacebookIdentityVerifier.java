package com.viegym.auth.application;

public interface FacebookIdentityVerifier {
    FacebookIdentity verify(String accessToken);
}
