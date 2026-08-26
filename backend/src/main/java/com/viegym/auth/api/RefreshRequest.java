package com.viegym.auth.api;

public record RefreshRequest(String refreshToken, String deviceInfo) {}
