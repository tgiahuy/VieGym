package com.viegym.admin.user.api;

import java.time.OffsetDateTime;

public final class AdminUserDtos {
    private AdminUserDtos() {}

    public record UserSummary(
            Long id,
            String email,
            String displayName,
            String role,
            String status,
            String authProvider,
            OffsetDateTime lastLoginAt,
            OffsetDateTime createdAt,
            OffsetDateTime updatedAt) {}

    public record UpdateUserStatusRequest(String status, String reason) {}

    public record InviteUserRequest(String email, String fullName, String role, String notes) {}
}
