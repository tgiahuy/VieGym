//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/equipment_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'equipment_preference_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EquipmentPreferenceResponse {
  /// Returns a new [EquipmentPreferenceResponse] instance.
  EquipmentPreferenceResponse({
    this.selectedEquipmentIds,

    this.equipment,

    this.equipmentOnboardingCompletedAt,
  });

  @JsonKey(name: r'selectedEquipmentIds', required: false, includeIfNull: false)
  final List<int>? selectedEquipmentIds;

  @JsonKey(name: r'equipment', required: false, includeIfNull: false)
  final List<EquipmentItem>? equipment;

  @JsonKey(
    name: r'equipmentOnboardingCompletedAt',
    required: false,
    includeIfNull: false,
  )
  final DateTime? equipmentOnboardingCompletedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentPreferenceResponse &&
          other.selectedEquipmentIds == selectedEquipmentIds &&
          other.equipment == equipment &&
          other.equipmentOnboardingCompletedAt ==
              equipmentOnboardingCompletedAt;

  @override
  int get hashCode =>
      selectedEquipmentIds.hashCode +
      equipment.hashCode +
      equipmentOnboardingCompletedAt.hashCode;

  factory EquipmentPreferenceResponse.fromJson(Map<String, dynamic> json) =>
      _$EquipmentPreferenceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentPreferenceResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
