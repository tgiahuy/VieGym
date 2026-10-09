import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for WorkoutSchedulePlanningControllerApi
void main() {
  final instance = ViegymApi().getWorkoutSchedulePlanningControllerApi();

  group(WorkoutSchedulePlanningControllerApi, () {
    //Future<ApiResponseApplyScheduleProposalResponse> apply(int id) async
    test('test apply', () async {
      // TODO
    });

    //Future<ApiResponseScheduleProposalResponse> create1(CreateScheduleProposalRequest createScheduleProposalRequest) async
    test('test create1', () async {
      // TODO
    });

    //Future<ApiResponseScheduleProposalResponse> get3(int id) async
    test('test get3', () async {
      // TODO
    });
  });
}
