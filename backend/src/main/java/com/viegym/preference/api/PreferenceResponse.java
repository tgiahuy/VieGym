package com.viegym.preference.api;

import java.time.LocalTime;
import java.util.List;
import java.util.Map;

public record PreferenceResponse(
        List<String> dislikedFoods,
        List<String> allergies,
        List<String> dietaryConstraints,
        Map<String, Object> mealPreferences,
        Map<String, Object> trainingPreferences,
        LocalTime preferredTrainingTime) {}
