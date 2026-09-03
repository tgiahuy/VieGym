import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/onboarding/application/health_profile_controller.dart';
import 'package:viegym/features/onboarding/data/health_profile_repository.dart';
import 'package:viegym/features/onboarding/domain/user_profile_models.dart';

void main() {
  group('DioHealthProfileRepository tests', () {
    late _MockHealthApiAdapter adapter;
    late Dio dio;
    late DioHealthProfileRepository repo;

    setUp(() {
      adapter = _MockHealthApiAdapter();
      dio = Dio()..httpClientAdapter = adapter;
      repo = DioHealthProfileRepository(dio);
    });

    test('createProfile sends correct payload and parses response', () async {
      const inputProfile = HealthProfile(
        nickname: 'Gia Huy',
        gender: BiologicalGender.male,
        age: 25,
        heightCm: 175,
        weightKg: 70,
        goal: FitnessGoal.gainMuscle,
        activityLevel: ActivityLevel.active,
        experience: TrainingExperience.intermediate,
      );

      final result = await repo.createProfile(inputProfile);

      expect(adapter.lastPostPath, '/api/v1/health/profile');
      expect(adapter.lastPostData?['gender'], 'MALE');
      expect(adapter.lastPostData?['currentWeightKg'], 70.0);
      expect(adapter.lastPostData?['fitnessGoal'], 'GAIN_MUSCLE');
      expect(adapter.lastPostData?['activityLevel'], 'ACTIVE');

      expect(result.nickname, 'Gia Huy');
      expect(result.bmi, 22.86);
      expect(result.bmr, 1674);
      expect(result.tdee, 2895);
      expect(result.targetCalories, 3195);
      expect(result.isCompleted, isTrue);
    });

    test('getProfile returns parsed profile or null on 404', () async {
      final existing = await repo.getProfile();
      expect(existing, isNotNull);
      expect(existing?.heightCm, 175);
      expect(existing?.bmi, 22.86);

      adapter.return404 = true;
      final notFound = await repo.getProfile();
      expect(notFound, isNull);
    });

    test(
      'updateProfile excludes currentWeightKg and updates successfully',
      () async {
        const editProfile = HealthProfile(
          gender: BiologicalGender.male,
          age: 26,
          heightCm: 176,
          weightKg: 72,
          goal: FitnessGoal.loseFat,
          activityLevel: ActivityLevel.veryActive,
          experience: TrainingExperience.advanced,
        );

        final result = await repo.updateProfile(editProfile);

        expect(adapter.lastPutPath, '/api/v1/health/profile');
        expect(adapter.lastPutData?.containsKey('currentWeightKg'), isFalse);
        expect(adapter.lastPutData?['fitnessGoal'], 'LOSE_WEIGHT');
        expect(adapter.lastPutData?['activityLevel'], 'VERY_ACTIVE');
        expect(result.isCompleted, isTrue);
      },
    );

    test(
      'saveEquipmentPreferences fetches catalog, maps IDs, and puts preferences',
      () async {
        await repo.saveEquipmentPreferences({'db', 'bb', 'bw'});

        expect(adapter.lastPutPath, '/api/v1/preferences/equipment');
        final ids = adapter.lastPutData?['equipmentIds'] as List<dynamic>?;
        expect(ids, isNotNull);
        // 'db' -> DUMBBELL (2), 'bb' -> BARBELL (3), 'bw' -> BODYWEIGHT (1)
        expect(ids, containsAll([1, 2, 3]));
      },
    );
  });

  group('HealthProfileController remote synchronization tests', () {
    test('loadProfileFromRemote and submitInitialProfile sync state', () async {
      final adapter = _MockHealthApiAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final repo = DioHealthProfileRepository(dio);

      final container = ProviderContainer(
        overrides: [healthProfileRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(healthProfileProvider.notifier);

      // 1. Initial submit
      controller.updateNickname('Gia Huy');
      controller.updateHeight(175);
      controller.updateWeight(70);
      await controller.submitInitialProfile();

      expect(container.read(healthProfileProvider).isCompleted, isTrue);
      expect(container.read(healthProfileProvider).nickname, 'Gia Huy');
      expect(container.read(healthProfileProvider).bmi, 22.86);

      // 2. Load remote
      final loadSuccess = await controller.loadProfileFromRemote();
      expect(loadSuccess, isTrue);
      expect(container.read(healthProfileProvider).heightCm, 175);
    });
  });
}

class _MockHealthApiAdapter implements HttpClientAdapter {
  bool return404 = false;
  String? lastPostPath;
  Map<String, dynamic>? lastPostData;
  String? lastPutPath;
  Map<String, dynamic>? lastPutData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/api/v1/health/profile') {
      if (return404) {
        return _jsonResponse(404, {'message': 'Profile not found'});
      }

      if (options.method == 'POST') {
        lastPostPath = options.path;
        lastPostData = options.data as Map<String, dynamic>?;
        return _jsonResponse(201, {
          'success': true,
          'data': {
            'profile': {
              'dateOfBirth': lastPostData?['dateOfBirth'] ?? '2001-01-01',
              'gender': lastPostData?['gender'] ?? 'MALE',
              'calculationSex': 'MALE',
              'heightCm': lastPostData?['heightCm'] ?? 175.0,
              'currentWeightKg': lastPostData?['currentWeightKg'] ?? 70.0,
              'activityLevel': lastPostData?['activityLevel'] ?? 'ACTIVE',
              'fitnessGoal': lastPostData?['fitnessGoal'] ?? 'GAIN_MUSCLE',
              'trainingExperience':
                  lastPostData?['trainingExperience'] ?? 'INTERMEDIATE',
              'calculationVersion': 'viegym-health-v1',
              'calculatedAt': '2026-09-03T06:00:00Z',
            },
            'calculationStatus': 'COMPLETE',
            'metrics': {'bmi': 22.86, 'bmrKcal': 1674, 'tdeeKcal': 2895},
            'nutritionTarget': {
              'caloriesKcal': 3195,
              'proteinG': 140.0,
              'carbsG': 400.0,
              'fatG': 90.0,
            },
          },
        });
      }

      if (options.method == 'PUT') {
        lastPutPath = options.path;
        lastPutData = options.data as Map<String, dynamic>?;
        return _jsonResponse(200, {
          'success': true,
          'data': {
            'profile': {
              'dateOfBirth': '2000-01-01',
              'gender': lastPutData?['gender'] ?? 'MALE',
              'calculationSex': 'MALE',
              'heightCm': lastPutData?['heightCm'] ?? 176.0,
              'currentWeightKg': 72.0,
              'activityLevel': lastPutData?['activityLevel'] ?? 'VERY_ACTIVE',
              'fitnessGoal': lastPutData?['fitnessGoal'] ?? 'LOSE_WEIGHT',
              'trainingExperience':
                  lastPutData?['trainingExperience'] ?? 'ADVANCED',
              'calculationVersion': 'viegym-health-v1',
              'calculatedAt': '2026-09-03T06:00:00Z',
            },
            'calculationStatus': 'COMPLETE',
            'metrics': {'bmi': 23.24, 'bmrKcal': 1710, 'tdeeKcal': 2950},
            'nutritionTarget': {
              'caloriesKcal': 2550,
              'proteinG': 150.0,
              'carbsG': 300.0,
              'fatG': 70.0,
            },
          },
        });
      }

      // GET
      return _jsonResponse(200, {
        'success': true,
        'data': {
          'profile': {
            'dateOfBirth': '2001-01-01',
            'gender': 'MALE',
            'calculationSex': 'MALE',
            'heightCm': 175.0,
            'currentWeightKg': 70.0,
            'activityLevel': 'ACTIVE',
            'fitnessGoal': 'GAIN_MUSCLE',
            'trainingExperience': 'INTERMEDIATE',
            'calculationVersion': 'viegym-health-v1',
            'calculatedAt': '2026-09-03T06:00:00Z',
          },
          'calculationStatus': 'COMPLETE',
          'metrics': {'bmi': 22.86, 'bmrKcal': 1674, 'tdeeKcal': 2895},
          'nutritionTarget': {
            'caloriesKcal': 3195,
            'proteinG': 140.0,
            'carbsG': 400.0,
            'fatG': 90.0,
          },
        },
      });
    }

    if (options.path == '/api/v1/preferences/equipment') {
      if (options.method == 'GET') {
        return _jsonResponse(200, {
          'success': true,
          'data': {
            'selected': [1],
            'catalog': [
              {'id': 1, 'code': 'BODYWEIGHT', 'name': 'Trọng lượng cơ thể'},
              {'id': 2, 'code': 'DUMBBELL', 'name': 'Tạ đơn'},
              {'id': 3, 'code': 'BARBELL', 'name': 'Tạ đòn'},
              {'id': 4, 'code': 'BENCH', 'name': 'Ghế tập'},
            ],
            'completedAt': '2026-09-03T06:00:00Z',
          },
        });
      }

      if (options.method == 'PUT') {
        lastPutPath = options.path;
        lastPutData = options.data as Map<String, dynamic>?;
        return _jsonResponse(200, {
          'success': true,
          'data': {
            'selected': lastPutData?['equipmentIds'] ?? [],
            'catalog': [],
            'completedAt': '2026-09-03T06:00:00Z',
          },
        });
      }
    }

    return _jsonResponse(404, {'message': 'Not found'});
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
