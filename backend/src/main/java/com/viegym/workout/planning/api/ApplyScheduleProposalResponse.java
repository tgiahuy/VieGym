package com.viegym.workout.planning.api;

import com.viegym.workout.schedule.api.WorkoutScheduleResponse;
import java.util.List;

public record ApplyScheduleProposalResponse(
        Long proposalId, String status, List<WorkoutScheduleResponse> schedules) {}
