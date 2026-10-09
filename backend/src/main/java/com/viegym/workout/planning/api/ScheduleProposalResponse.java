package com.viegym.workout.planning.api;

import java.time.OffsetDateTime;
import java.util.List;

public record ScheduleProposalResponse(
        Long id,
        String sourceType,
        String scope,
        Long sourceId,
        Integer sourceVersion,
        String status,
        OffsetDateTime expiresAt,
        OffsetDateTime appliedAt,
        List<ScheduleProposalItemResponse> items) {}
