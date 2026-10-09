import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for WeightLogControllerApi
void main() {
  final instance = ViegymApi().getWeightLogControllerApi();

  group(WeightLogControllerApi, () {
    //Future<ApiResponsePageResponseWeightLogDto> list({ DateTime from, DateTime to, int page, int size }) async
    test('test list', () async {
      // TODO
    });

    //Future<ApiResponseWeightTrendResponse> trend({ int days }) async
    test('test trend', () async {
      // TODO
    });

    //Future<ApiResponseUpsertWeightLogResponse> upsert(DateTime loggedDate, UpsertWeightLogRequest upsertWeightLogRequest) async
    test('test upsert', () async {
      // TODO
    });
  });
}
