import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for WorkoutProgramControllerApi
void main() {
  final instance = ViegymApi().getWorkoutProgramControllerApi();

  group(WorkoutProgramControllerApi, () {
    //Future<ApiResponseVoid> archiveProgram(int id) async
    test('test archiveProgram', () async {
      // TODO
    });

    //Future<ApiResponseWorkoutProgramResponse> createProgram(WorkoutProgramRequest workoutProgramRequest) async
    test('test createProgram', () async {
      // TODO
    });

    //Future<ApiResponseWorkoutProgramResponse> getProgram(int id) async
    test('test getProgram', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseWorkoutProgramSummaryResponse> listPrograms({ String status, int page, int size }) async
    test('test listPrograms', () async {
      // TODO
    });

    //Future<ApiResponseWorkoutProgramResponse> updateProgram(int id, WorkoutProgramRequest workoutProgramRequest) async
    test('test updateProgram', () async {
      // TODO
    });
  });
}
