import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for ExerciseCatalogControllerApi
void main() {
  final instance = ViegymApi().getExerciseCatalogControllerApi();

  group(ExerciseCatalogControllerApi, () {
    //Future<ApiResponseVoid> addFavorite1(int exerciseId) async
    test('test addFavorite1', () async {
      // TODO
    });

    //Future<ApiResponseListExerciseSummaryDto> getExerciseAlternatives(int id, { int limit }) async
    test('test getExerciseAlternatives', () async {
      // TODO
    });

    //Future<ApiResponseExerciseDetailDto> getExerciseDetail(int id) async
    test('test getExerciseDetail', () async {
      // TODO
    });

    //Future<ApiResponseListEquipmentDto> listEquipment() async
    test('test listEquipment', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseExerciseSummaryDto> listFavoriteExercises({ String q, int page, int size }) async
    test('test listFavoriteExercises', () async {
      // TODO
    });

    //Future<ApiResponseListMuscleGroupDto> listMuscleGroups() async
    test('test listMuscleGroups', () async {
      // TODO
    });

    //Future<ApiResponseVoid> removeFavorite1(int exerciseId) async
    test('test removeFavorite1', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseExerciseSummaryDto> searchExercises({ String q, int muscleGroupId, int equipmentId, String difficulty, bool compatibleWithMyEquipment, int page, int size, String sort }) async
    test('test searchExercises', () async {
      // TODO
    });
  });
}
