import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for DashboardControllerApi
void main() {
  final instance = ViegymApi().getDashboardControllerApi();

  group(DashboardControllerApi, () {
    //Future<ApiResponseDashboardResponse> getDashboard({ DateTime date }) async
    test('test getDashboard', () async {
      // TODO
    });
  });
}
