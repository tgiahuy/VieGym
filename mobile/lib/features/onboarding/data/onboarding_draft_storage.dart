import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/user_profile_models.dart';

final onboardingDraftStorageProvider = Provider<OnboardingDraftStorage>((ref) {
  return OnboardingDraftStorage();
});

class OnboardingDraft {
  const OnboardingDraft({
    required this.currentStep,
    required this.profile,
    this.healthCompleted = false,
    this.equipmentCompleted = false,
    this.equipmentIds = const [],
    this.genderSelected = false,
    this.goalSelected = false,
    this.activitySelected = false,
    this.experienceSelected = false,
    this.daysSelected = false,
    this.durationSelected = false,
  });

  factory OnboardingDraft.fromJson(Map<String, dynamic> json) {
    final dobRaw = json['dateOfBirth'] as String?;
    final dob = dobRaw != null ? DateTime.tryParse(dobRaw) : null;

    return OnboardingDraft(
      currentStep: (json['currentStep'] as int? ?? 1).clamp(1, 12),
      healthCompleted: json['healthCompleted'] as bool? ?? false,
      equipmentCompleted: json['equipmentCompleted'] as bool? ?? false,
      equipmentIds: (json['equipmentIds'] as List<dynamic>? ?? const [])
          .map((e) => '$e')
          .toList(),
      genderSelected: json['genderSelected'] as bool? ?? false,
      goalSelected: json['goalSelected'] as bool? ?? false,
      activitySelected: json['activitySelected'] as bool? ?? false,
      experienceSelected: json['experienceSelected'] as bool? ?? false,
      daysSelected: json['daysSelected'] as bool? ?? false,
      durationSelected: json['durationSelected'] as bool? ?? false,
      profile: HealthProfile(
        nickname: json['nickname'] as String? ?? '',
        gender: BiologicalGender.values.firstWhere(
          (g) => g.name == json['gender'],
          orElse: () => BiologicalGender.male,
        ),
        age: json['age'] as int? ?? 25,
        dateOfBirth: dob,
        heightCm: json['heightCm'] as int? ?? 170,
        weightKg: json['weightKg'] as int? ?? 65,
        targetWeightKg: json['targetWeightKg'] as int? ?? 65,
        goal: FitnessGoal.values.firstWhere(
          (g) => g.name == json['goal'],
          orElse: () => FitnessGoal.gainMuscle,
        ),
        activityLevel: ActivityLevel.values.firstWhere(
          (a) => a.name == json['activityLevel'],
          orElse: () => ActivityLevel.active,
        ),
        roadmapWeeks: json['roadmapWeeks'] as int? ?? 8,
        experience: TrainingExperience.values.firstWhere(
          (e) => e.name == json['experience'],
          orElse: () => TrainingExperience.intermediate,
        ),
        workoutDaysPerWeek: json['workoutDaysPerWeek'] as int? ?? 4,
        sessionDurationMinutes: json['sessionDurationMinutes'] as int? ?? 60,
        isCompleted: json['healthCompleted'] as bool? ?? false,
      ),
    );
  }

  final int currentStep;
  final HealthProfile profile;
  final bool healthCompleted;
  final bool equipmentCompleted;
  final List<String> equipmentIds;
  final bool genderSelected;
  final bool goalSelected;
  final bool activitySelected;
  final bool experienceSelected;
  final bool daysSelected;
  final bool durationSelected;

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'healthCompleted': healthCompleted,
      'equipmentCompleted': equipmentCompleted,
      'equipmentIds': equipmentIds,
      'genderSelected': genderSelected,
      'goalSelected': goalSelected,
      'activitySelected': activitySelected,
      'experienceSelected': experienceSelected,
      'daysSelected': daysSelected,
      'durationSelected': durationSelected,
      'nickname': profile.nickname,
      'gender': profile.gender.name,
      'age': profile.age,
      'dateOfBirth': profile.dateOfBirth?.toIso8601String(),
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'targetWeightKg': profile.targetWeightKg,
      'goal': profile.goal.name,
      'activityLevel': profile.activityLevel.name,
      'roadmapWeeks': profile.roadmapWeeks,
      'experience': profile.experience.name,
      'workoutDaysPerWeek': profile.workoutDaysPerWeek,
      'sessionDurationMinutes': profile.sessionDurationMinutes,
    };
  }
}

class OnboardingDraftStorage {
  OnboardingDraftStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyPrefix = 'viegym_onboarding_draft_';

  String _keyFor(String accountKey) {
    final normalized = accountKey.trim().isEmpty
        ? 'default'
        : accountKey.trim().toLowerCase();
    return '$_keyPrefix$normalized';
  }

  Future<void> save(String accountKey, OnboardingDraft draft) async {
    try {
      await _storage.write(
        key: _keyFor(accountKey),
        value: jsonEncode(draft.toJson()),
      );
    } catch (_) {
      // Best-effort local persistence; ignore storage errors in tests/unsupported platforms.
    }
  }

  Future<OnboardingDraft?> load(String accountKey) async {
    try {
      final raw = await _storage.read(key: _keyFor(accountKey));
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return OnboardingDraft.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String accountKey) async {
    try {
      await _storage.delete(key: _keyFor(accountKey));
    } catch (_) {
      // Ignore storage errors.
    }
  }
}
