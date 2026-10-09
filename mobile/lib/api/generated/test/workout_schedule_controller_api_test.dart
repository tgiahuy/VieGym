import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for WorkoutScheduleControllerApi
void main() {
  final instance = ViegymApi().getWorkoutScheduleControllerApi();

  group(WorkoutScheduleControllerApi, () {
    //Future<ApiResponseVoid> cancelSchedule(int id, { String cancelReason }) async
    test('test cancelSchedule', () async {
      // TODO
    });

    //Future<ApiResponseWorkoutScheduleResponse> createSchedule(WorkoutScheduleRequest workoutScheduleRequest) async
    test('test createSchedule', () async {
      // TODO
    });

    //Future<ApiResponseWorkoutScheduleResponse> getSchedule(int id) async
    test('test getSchedule', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseWorkoutScheduleResponse> listSchedules({ DateTime from, DateTime to, String status, int page, int size }) async
    test('test listSchedules', () async {
      // TODO
    });

    //Future<ApiResponseWorkoutScheduleResponse> updateSchedule(int id, WorkoutScheduleRequest workoutScheduleRequest) async
    test('test updateSchedule', () async {
      // TODO
    });
  });
}
