import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for WorkoutSessionControllerApi
void main() {
  final instance = ViegymApi().getWorkoutSessionControllerApi();

  group(WorkoutSessionControllerApi, () {
    //Future<ApiResponseVoid> discardSession(int id, { DiscardSessionRequest discardSessionRequest }) async
    test('test discardSession', () async {
      // TODO
    });

    //Future<ApiResponseFinishSessionResponse> finishSession(int id, FinishSessionRequest finishSessionRequest) async
    test('test finishSession', () async {
      // TODO
    });

    //Future<ApiResponsePauseSessionResponse> pauseSession(int id) async
    test('test pauseSession', () async {
      // TODO
    });

    //Future<ApiResponseResumeSessionResponse> resumeSession(int id) async
    test('test resumeSession', () async {
      // TODO
    });

    //Future<ApiResponseStartSessionResponse> startSession(int scheduleId) async
    test('test startSession', () async {
      // TODO
    });
  });
}
