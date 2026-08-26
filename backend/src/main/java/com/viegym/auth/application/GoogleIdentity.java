package com.viegym.auth.application;

public record GoogleIdentity(String subject, String email, String displayName) {}
