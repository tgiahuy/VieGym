package com.viegym.admin.auth.api;

public record AdminSessionResponse(AdminIdentityResponse admin, long expiresIn, String csrfToken) {}
