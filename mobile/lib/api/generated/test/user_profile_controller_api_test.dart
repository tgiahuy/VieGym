import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for UserProfileControllerApi
void main() {
  final instance = ViegymApi().getUserProfileControllerApi();

  group(UserProfileControllerApi, () {
    //Future<ApiResponseUserResponse> callGet() async
    test('test callGet', () async {
      // TODO
    });

    //Future<ApiResponseUserResponse> update(UpdateUserRequest updateUserRequest) async
    test('test update', () async {
      // TODO
    });
  });
}
