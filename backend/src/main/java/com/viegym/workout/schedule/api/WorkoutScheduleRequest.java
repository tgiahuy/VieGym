package com.viegym.workout.schedule.api;

import java.time.LocalDate;
import java.time.LocalTime;

public record WorkoutScheduleRequest(
        Long workoutProgramId,
        Long workoutDayId,
        LocalDate scheduledDate,
        LocalTime scheduledTime,
        String title) {}
