package com.viegym.auth.application;

public interface GoogleIdentityVerifier {
    GoogleIdentity verify(String idToken);
}
