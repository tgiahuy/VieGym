package com.viegym.ai.application;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Exercises the AI planners must never suggest for a declared injury. Exclusion is by primary
 * muscle group and by lower-case name fragment (the catalog has no contraindication tags). The
 * lists err on the side of caution: a wrongly excluded exercise costs variety, a wrongly included
 * one can hurt the user.
 */
final class InjuryExerciseRules {
    private InjuryExerciseRules() {}

    private record Rule(List<String> muscles, List<String> nameFragments) {}

    private static final Map<String, Rule> RULES =
            Map.of(
                    "LOWER_BACK",
                    new Rule(
                            List.of("LOWER_BACK"),
                            List.of(
                                    "deadlift",
                                    "good morning",
                                    "back squat",
                                    "barbell squat",
                                    "bent over row",
                                    "bent-over row",
                                    "bent over barbell row",
                                    "hyperextension",
                                    "jefferson",
                                    "clean",
                                    "snatch")),
                    "KNEE",
                    new Rule(
                            List.of(),
                            List.of(
                                    "jump",
                                    "lunge",
                                    "pistol",
                                    "sissy squat",
                                    "leg extension",
                                    "split squat",
                                    "plyo",
                                    "burpee")),
                    "SHOULDER",
                    new Rule(
                            List.of(),
                            List.of(
                                    "overhead press",
                                    "military press",
                                    "behind the neck",
                                    "behind neck",
                                    "upright row",
                                    "dip",
                                    "snatch",
                                    "handstand",
                                    "push press",
                                    "arnold press",
                                    "kipping")),
                    "WRIST",
                    new Rule(
                            List.of("FOREARMS"),
                            List.of(
                                    "push-up",
                                    "push up",
                                    "pushup",
                                    "front squat",
                                    "clean",
                                    "handstand",
                                    "wrist",
                                    "planche",
                                    "plank")),
                    "ELBOW",
                    new Rule(
                            List.of(),
                            List.of(
                                    "skull crusher",
                                    "dip",
                                    "close-grip",
                                    "close grip",
                                    "lying triceps")),
                    "NECK",
                    new Rule(
                            List.of("NECK"),
                            List.of("shrug", "neck", "bridge", "upright row", "behind the neck")),
                    "ANKLE",
                    new Rule(
                            List.of("CALVES"),
                            List.of(
                                    "jump",
                                    "calf raise",
                                    "box",
                                    "skipping",
                                    "jump rope",
                                    "sprint",
                                    "plyo")),
                    "HIP",
                    new Rule(
                            List.of("ADDUCTORS", "ABDUCTORS"),
                            List.of("sumo", "lunge", "deep squat", "split squat", "hip thrust")));

    static Set<String> excludedMuscles(Collection<String> injuries) {
        Set<String> muscles = new LinkedHashSet<>();
        for (String injury : injuries) {
            Rule rule = RULES.get(injury);
            if (rule != null) muscles.addAll(rule.muscles());
        }
        return muscles;
    }

    static Set<String> excludedNameFragments(Collection<String> injuries) {
        Set<String> fragments = new LinkedHashSet<>();
        for (String injury : injuries) {
            Rule rule = RULES.get(injury);
            if (rule != null) fragments.addAll(rule.nameFragments());
        }
        return fragments;
    }
}
