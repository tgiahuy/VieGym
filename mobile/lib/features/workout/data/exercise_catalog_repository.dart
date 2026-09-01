import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/exercise_api_models.dart';

final exerciseCatalogRepositoryProvider = Provider<ExerciseCatalogRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ExerciseCatalogRepository(dio);
});

class ExerciseCatalogRepository {
  const ExerciseCatalogRepository(this._dio);

  final Dio _dio;

  Future<ExercisePageResult> getExercises({
    String? q,
    int? muscleGroupId,
    int? equipmentId,
    String? difficulty,
    bool? compatibleWithMyEquipment,
    int page = 0,
    int size = 150,
    String sort = 'name,asc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
    };
    if (q != null && q.trim().isNotEmpty) {
      queryParams['q'] = q.trim();
    }
    if (muscleGroupId != null) {
      queryParams['muscleGroupId'] = muscleGroupId;
    }
    if (equipmentId != null) {
      queryParams['equipmentId'] = equipmentId;
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      queryParams['difficulty'] = difficulty;
    }
    if (compatibleWithMyEquipment != null) {
      queryParams['compatibleWithMyEquipment'] = compatibleWithMyEquipment;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/exercises',
      queryParameters: queryParams,
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    final content =
        (data['content'] as List<dynamic>?)
            ?.map((e) => ExerciseApiSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final totalElements = data['totalElements'] as int? ?? content.length;
    final totalPages = data['totalPages'] as int? ?? 1;
    final hasNext = data['hasNext'] as bool? ?? false;
    final last = data['last'] as bool? ?? (!hasNext);

    return ExercisePageResult(
      items: content,
      totalElements: totalElements,
      totalPages: totalPages,
      isLastPage: last,
    );
  }

  Future<ExerciseApiDetail> getExerciseDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/exercises/$id',
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    return ExerciseApiDetail.fromJson(data);
  }

  Future<List<ExerciseApiSummary>> getAlternatives(
    int id, {
    int limit = 5,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/exercises/$id/alternatives',
      queryParameters: {'limit': limit},
    );
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => ExerciseApiSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MuscleGroupItem>> getMuscleGroups() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/muscle-groups',
    );
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => MuscleGroupItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EquipmentItem>> getEquipment() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/equipment');
    final list = response.data?['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ExercisePageResult> getFavorites({
    String? q,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (q != null && q.trim().isNotEmpty) {
      queryParams['q'] = q.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/favorite-exercises',
      queryParameters: queryParams,
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    final content =
        (data['content'] as List<dynamic>?)
            ?.map((e) => ExerciseApiSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final totalElements = data['totalElements'] as int? ?? content.length;
    final totalPages = data['totalPages'] as int? ?? 1;
    final last = data['last'] as bool? ?? true;

    return ExercisePageResult(
      items: content,
      totalElements: totalElements,
      totalPages: totalPages,
      isLastPage: last,
    );
  }

  Future<void> addFavorite(int exerciseId) async {
    await _dio.put<Map<String, dynamic>>(
      '/api/v1/favorite-exercises/$exerciseId',
    );
  }

  Future<void> removeFavorite(int exerciseId) async {
    await _dio.delete<Map<String, dynamic>>(
      '/api/v1/favorite-exercises/$exerciseId',
    );
  }
}

class ExercisePageResult {
  const ExercisePageResult({
    required this.items,
    required this.totalElements,
    required this.totalPages,
    required this.isLastPage,
  });

  final List<ExerciseApiSummary> items;
  final int totalElements;
  final int totalPages;
  final bool isLastPage;
}
