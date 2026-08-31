import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for PreferenceControllerApi
void main() {
  final instance = ViegymApi().getPreferenceControllerApi();

  group(PreferenceControllerApi, () {
    //Future<ApiResponsePreferenceResponse> get1() async
    test('test get1', () async {
      // TODO
    });

    //Future<ApiResponseEquipmentPreferenceResponse> getEquipment() async
    test('test getEquipment', () async {
      // TODO
    });

    //Future<ApiResponsePreferenceResponse> put(PreferenceRequest preferenceRequest) async
    test('test put', () async {
      // TODO
    });

    //Future<ApiResponseEquipmentPreferenceResponse> putEquipment(EquipmentPreferenceRequest equipmentPreferenceRequest) async
    test('test putEquipment', () async {
      // TODO
    });
  });
}
