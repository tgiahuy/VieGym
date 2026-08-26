package com.viegym.auth.api;

public record LoginRequest(String email, String password, String deviceInfo) {}
