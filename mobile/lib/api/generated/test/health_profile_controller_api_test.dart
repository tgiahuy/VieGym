import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for HealthProfileControllerApi
void main() {
  final instance = ViegymApi().getHealthProfileControllerApi();

  group(HealthProfileControllerApi, () {
    //Future<ApiResponseHealthProfileResponse> create(CreateHealthProfileRequest createHealthProfileRequest) async
    test('test create', () async {
      // TODO
    });
  });
}
