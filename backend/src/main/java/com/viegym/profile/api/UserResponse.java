package com.viegym.profile.api;

import java.time.OffsetDateTime;

public record UserResponse(
        Long id,
        String email,
        String displayName,
        AvatarResponse avatar,
        String timezone,
        String locale,
        String role,
        String authProvider,
        OnboardingResponse onboarding) {

    public record AvatarResponse(Long mediaId, String accessUrl, OffsetDateTime expiresAt) {}

    public record OnboardingResponse(boolean healthProfileCompleted, boolean equipmentCompleted) {}
}
