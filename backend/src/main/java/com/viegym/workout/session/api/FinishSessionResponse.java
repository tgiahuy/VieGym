package com.viegym.workout.session.api;

import com.viegym.workout.log.api.PersonalRecordDto;
import java.util.List;

public record FinishSessionResponse(
        Long workoutLogId,
        Long workoutSessionId,
        int durationSeconds,
        Double totalVolumeKg,
        List<PersonalRecordDto> newPersonalRecords) {}
