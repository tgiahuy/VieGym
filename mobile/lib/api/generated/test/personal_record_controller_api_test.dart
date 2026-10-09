import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for PersonalRecordControllerApi
void main() {
  final instance = ViegymApi().getPersonalRecordControllerApi();

  group(PersonalRecordControllerApi, () {
    //Future<ApiResponsePageResponsePersonalRecordDto> listPersonalRecords({ int exerciseId, String type, int page, int size }) async
    test('test listPersonalRecords', () async {
      // TODO
    });
  });
}
