package com.viegym.auth.application;

public record FacebookIdentity(String subject, String email, String displayName) {}
