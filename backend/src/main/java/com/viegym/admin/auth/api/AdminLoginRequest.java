package com.viegym.admin.auth.api;

public record AdminLoginRequest(String email, String password, String deviceInfo) {}
