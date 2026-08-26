package com.viegym.auth.api;

public record ChangePasswordRequest(String currentPassword, String newPassword) {}
