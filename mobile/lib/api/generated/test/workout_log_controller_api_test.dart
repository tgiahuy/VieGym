import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for WorkoutLogControllerApi
void main() {
  final instance = ViegymApi().getWorkoutLogControllerApi();

  group(WorkoutLogControllerApi, () {
    //Future<ApiResponseWorkoutLogDetailDto> getWorkoutLogDetail(int id) async
    test('test getWorkoutLogDetail', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseWorkoutLogSummaryDto> listWorkoutLogs({ DateTime from, DateTime to, int exerciseId, int page, int size }) async
    test('test listWorkoutLogs', () async {
      // TODO
    });
  });
}
