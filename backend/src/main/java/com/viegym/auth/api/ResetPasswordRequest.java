package com.viegym.auth.api;

public record ResetPasswordRequest(String resetProof, String newPassword) {}
