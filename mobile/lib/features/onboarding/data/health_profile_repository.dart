import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/user_profile_models.dart';

final healthProfileRepositoryProvider = Provider<HealthProfileRepository>((
  ref,
) {
  return DioHealthProfileRepository(ref.watch(dioProvider));
});

abstract class HealthProfileRepository {
  Future<HealthProfile?> getProfile();

  Future<HealthProfile> createProfile(HealthProfile profile);

  Future<HealthProfile> updateProfile(HealthProfile profile);

  Future<void> saveEquipmentPreferences(Set<String> selectedLocalIds);
}

class DioHealthProfileRepository implements HealthProfileRepository {
  const DioHealthProfileRepository(this._dio);

  final Dio _dio;

  static const Map<String, String> _localCodeToBackendCode = {
    'db': 'DUMBBELL',
    'bb': 'BARBELL',
    'kb': 'KETTLEBELL',
    'bench': 'BENCH',
    'cable': 'CABLE_MACHINE',
    'smith': 'MACHINE',
    'lat_pulldown': 'MACHINE',
    'bw': 'BODYWEIGHT',
    'pullup_bar': 'PULL_UP_BAR',
    'band': 'RESISTANCE_BAND',
    'ez': 'BARBELL',
    'rack': 'BENCH',
  };

  @override
  Future<HealthProfile?> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/health/profile',
      );
      final data = _extractData(response.data);
      if (data.isEmpty) return null;
      return _parseResponse(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw HealthProfileApiException.fromDio(e);
    }
  }

  @override
  Future<HealthProfile> createProfile(HealthProfile profile) async {
    try {
      final dob = profile.effectiveDateOfBirth;
      final payload = {
        'dateOfBirth': _formatDate(dob),
        'gender': profile.gender.toBackendGender(),
        'calculationSex': profile.gender.toBackendCalculationSex(),
        'heightCm': profile.heightCm.toDouble(),
        'currentWeightKg': profile.weightKg.toDouble(),
        'activityLevel': profile.activityLevel.toBackend(),
        'fitnessGoal': profile.goal.toBackend(),
        'trainingExperience': profile.experience.toBackend(),
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/health/profile',
        data: payload,
      );
      final data = _extractData(response.data);
      final parsed = _parseResponse(data);
      return parsed.copyWith(nickname: profile.nickname);
    } on DioException catch (e) {
      throw HealthProfileApiException.fromDio(e);
    }
  }

  @override
  Future<HealthProfile> updateProfile(HealthProfile profile) async {
    try {
      final dob = profile.effectiveDateOfBirth;
      final payload = {
        'dateOfBirth': _formatDate(dob),
        'gender': profile.gender.toBackendGender(),
        'calculationSex': profile.gender.toBackendCalculationSex(),
        'heightCm': profile.heightCm.toDouble(),
        'activityLevel': profile.activityLevel.toBackend(),
        'fitnessGoal': profile.goal.toBackend(),
        'trainingExperience': profile.experience.toBackend(),
      };

      final response = await _dio.put<Map<String, dynamic>>(
        '/api/v1/health/profile',
        data: payload,
      );
      final data = _extractData(response.data);
      final parsed = _parseResponse(data);
      return parsed.copyWith(
        nickname: profile.nickname,
        weightKg: profile.weightKg,
        targetWeightKg: profile.targetWeightKg,
      );
    } on DioException catch (e) {
      throw HealthProfileApiException.fromDio(e);
    }
  }

  @override
  Future<void> saveEquipmentPreferences(Set<String> selectedLocalIds) async {
    try {
      // 1. Fetch catalog to resolve equipment IDs
      final catalogResponse = await _dio.get<Map<String, dynamic>>(
        '/api/v1/preferences/equipment',
      );
      final catalogData = _extractData(catalogResponse.data);
      final catalogItems = catalogData['catalog'] as List<dynamic>? ?? [];

      final targetCodes = <String>{};
      for (final localId in selectedLocalIds) {
        final backendCode = _localCodeToBackendCode[localId];
        if (backendCode != null) {
          targetCodes.add(backendCode);
        }
      }

      final resolvedIds = <int>[];
      for (final item in catalogItems) {
        if (item is Map<String, dynamic>) {
          final code = item['code'] as String?;
          final id = item['id'];
          if (code != null && targetCodes.contains(code) && id != null) {
            resolvedIds.add(id is int ? id : int.parse(id.toString()));
          }
        }
      }

      // 2. Put selected equipment IDs to persist and mark equipmentOnboardingCompletedAt
      await _dio.put<Map<String, dynamic>>(
        '/api/v1/preferences/equipment',
        data: {'equipmentIds': resolvedIds},
      );
    } on DioException catch (e) {
      throw HealthProfileApiException.fromDio(e);
    }
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic>? body) {
    final data = body?['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static HealthProfile _parseResponse(Map<String, dynamic> data) {
    final profileMap = data['profile'] as Map<String, dynamic>? ?? {};
    final metricsMap = data['metrics'] as Map<String, dynamic>? ?? {};
    final targetMap = data['nutritionTarget'] as Map<String, dynamic>? ?? {};

    DateTime? dob;
    final dobStr = profileMap['dateOfBirth'] as String?;
    if (dobStr != null && dobStr.isNotEmpty) {
      try {
        dob = DateTime.parse(dobStr);
      } catch (_) {}
    }

    final nowYear = DateTime.now().year;
    final age = dob != null ? (nowYear - dob.year) : 25;
    final height = (profileMap['heightCm'] as num?)?.toInt() ?? 170;
    final weight = (profileMap['currentWeightKg'] as num?)?.toInt() ?? 65;

    final gender = BiologicalGender.fromBackend(
      profileMap['gender'] as String?,
    );
    final goal = FitnessGoal.fromBackend(profileMap['fitnessGoal'] as String?);
    final activity = ActivityLevel.fromBackend(
      profileMap['activityLevel'] as String?,
    );
    final experience = TrainingExperience.fromBackend(
      profileMap['trainingExperience'] as String?,
    );

    final bmi = (metricsMap['bmi'] as num?)?.toDouble();
    final bmr = (metricsMap['bmrKcal'] as num?)?.toInt();
    final tdee = (metricsMap['tdeeKcal'] as num?)?.toInt();

    final calTarget = (targetMap['caloriesKcal'] as num?)?.toInt();
    final protein = (targetMap['proteinG'] as num?)?.toDouble();
    final carbs = (targetMap['carbsG'] as num?)?.toDouble();
    final fat = (targetMap['fatG'] as num?)?.toDouble();

    return HealthProfile(
      gender: gender,
      age: age,
      dateOfBirth: dob,
      heightCm: height,
      weightKg: weight,
      targetWeightKg: weight,
      goal: goal,
      activityLevel: activity,
      experience: experience,
      isCompleted: true,
      serverBmi: bmi,
      serverBmr: bmr,
      serverTdee: tdee,
      targetCalories: calTarget,
      targetProtein: protein,
      targetCarbs: carbs,
      targetFat: fat,
    );
  }
}

class HealthProfileApiException implements Exception {
  const HealthProfileApiException({required this.code, required this.message});

  factory HealthProfileApiException.fromDio(DioException error) {
    final body = error.response?.data;
    final map = body is Map<String, dynamic> ? body : null;
    return HealthProfileApiException(
      code: map?['code'] as String? ?? 'NETWORK_ERROR',
      message:
          map?['message'] as String? ??
          'Không thể kết nối đến máy chủ hoặc dữ liệu không hợp lệ',
    );
  }

  final String code;
  final String message;

  @override
  String toString() => 'HealthProfileApiException($code): $message';
}
