import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/equipment_catalog.dart';
import '../data/health_profile_repository.dart';
import '../domain/user_profile_models.dart';

class HealthProfileController extends Notifier<HealthProfile> {
  @override
  HealthProfile build() => const HealthProfile();

  HealthProfileRepository get _repo =>
      ref.read(healthProfileRepositoryProvider);

  void completeProfile() {
    state = state.copyWith(isCompleted: true);
  }

  void resetProfile() {
    state = const HealthProfile(isCompleted: false);
  }

  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname.trim());
  }

  void updateGender(BiologicalGender gender) {
    state = state.copyWith(gender: gender);
  }

  void updateAge(int age) {
    state = state.copyWith(
      age: age,
      dateOfBirth: DateTime(DateTime.now().year - age, 1, 1),
    );
  }

  void updateDateOfBirth(DateTime dateOfBirth) {
    final now = DateTime.now();
    final calculatedAge = now.year - dateOfBirth.year;
    state = state.copyWith(
      dateOfBirth: dateOfBirth,
      age: calculatedAge > 0 ? calculatedAge : state.age,
    );
  }

  void updateHeight(int heightCm) {
    state = state.copyWith(heightCm: heightCm);
  }

  void updateWeight(int weightKg) {
    state = state.copyWith(weightKg: weightKg);
  }

  void updateTargetWeight(int targetWeightKg) {
    state = state.copyWith(targetWeightKg: targetWeightKg);
  }

  void updateGoal(FitnessGoal goal) {
    state = state.copyWith(goal: goal);
  }

  void updateActivityLevel(ActivityLevel level) {
    state = state.copyWith(activityLevel: level);
  }

  void updateExperience(TrainingExperience experience) {
    state = state.copyWith(experience: experience);
  }

  void updateWorkoutDaysPerWeek(int days) {
    state = state.copyWith(workoutDaysPerWeek: days);
  }

  void updateSessionDurationMinutes(int minutes) {
    state = state.copyWith(sessionDurationMinutes: minutes);
  }

  void updateProfile({
    String? nickname,
    BiologicalGender? gender,
    int? age,
    DateTime? dateOfBirth,
    int? heightCm,
    int? weightKg,
    int? targetWeightKg,
    FitnessGoal? goal,
    ActivityLevel? activityLevel,
    TrainingExperience? experience,
    int? workoutDaysPerWeek,
    int? sessionDurationMinutes,
    bool? isCompleted,
    double? serverBmi,
    int? serverBmr,
    int? serverTdee,
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) {
    state = state.copyWith(
      nickname: nickname,
      gender: gender,
      age: age,
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      weightKg: weightKg,
      targetWeightKg: targetWeightKg,
      goal: goal,
      activityLevel: activityLevel,
      experience: experience,
      workoutDaysPerWeek: workoutDaysPerWeek,
      sessionDurationMinutes: sessionDurationMinutes,
      isCompleted: isCompleted,
      serverBmi: serverBmi,
      serverBmr: serverBmr,
      serverTdee: serverTdee,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
    );
  }

  Future<bool> loadProfileFromRemote() async {
    try {
      final remote = await _repo.getProfile();
      if (remote != null) {
        state = remote.copyWith(
          nickname: state.nickname.isNotEmpty ? state.nickname : '',
          isCompleted: true,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> submitInitialProfile() async {
    final created = await _repo.createProfile(state);
    state = created.copyWith(
      nickname: state.nickname.isNotEmpty ? state.nickname : created.nickname,
      targetWeightKg: state.targetWeightKg,
      workoutDaysPerWeek: state.workoutDaysPerWeek,
      sessionDurationMinutes: state.sessionDurationMinutes,
      isCompleted: true,
    );
  }

  Future<void> saveEditedProfile() async {
    final updated = await _repo.updateProfile(state);
    state = updated.copyWith(
      nickname: state.nickname.isNotEmpty ? state.nickname : updated.nickname,
      targetWeightKg: state.targetWeightKg,
      workoutDaysPerWeek: state.workoutDaysPerWeek,
      sessionDurationMinutes: state.sessionDurationMinutes,
      isCompleted: true,
    );
  }
}

final healthProfileProvider =
    NotifierProvider<HealthProfileController, HealthProfile>(
      HealthProfileController.new,
    );

class UserEquipmentController extends Notifier<Set<String>> {
  @override
  Set<String> build() => EquipmentPresets.fullGym.toSet();

  void toggleEquipment(String id) {
    final updated = {...state};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;
  }

  void applyPreset(List<String> presetIds) {
    state = presetIds.toSet();
  }

  void selectAll() {
    state = masterEquipmentCatalogue.map((e) => e.id).toSet();
  }

  void clearAll() {
    state = {};
  }
}

final userEquipmentProvider =
    NotifierProvider<UserEquipmentController, Set<String>>(
      UserEquipmentController.new,
    );

class EquipmentOnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void complete() => state = true;
  void reset() => state = false;

  Future<void> saveAndComplete(Set<String> selectedIds) async {
    try {
      await ref
          .read(healthProfileRepositoryProvider)
          .saveEquipmentPreferences(selectedIds);
    } finally {
      state = true;
    }
  }
}

final equipmentOnboardingCompletedProvider =
    NotifierProvider<EquipmentOnboardingNotifier, bool>(
      EquipmentOnboardingNotifier.new,
    );

/// Navigation Guard Helper
/// Xác định route khởi tạo chính xác dựa theo trạng thái session và onboarding
String resolveOnboardingRoute({
  required bool isAuthenticated,
  required bool isHealthProfileCompleted,
  required bool isEquipmentOnboardingCompleted,
}) {
  if (!isAuthenticated) return '/welcome';
  if (!isHealthProfileCompleted) return '/onboarding/health';
  if (!isEquipmentOnboardingCompleted) return '/onboarding/equipment';
  return '/home';
}
