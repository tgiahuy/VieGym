//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'equipment_preference_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EquipmentPreferenceRequest {
  /// Returns a new [EquipmentPreferenceRequest] instance.
  EquipmentPreferenceRequest({this.equipmentIds});

  @JsonKey(name: r'equipmentIds', required: false, includeIfNull: false)
  final List<int>? equipmentIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentPreferenceRequest && other.equipmentIds == equipmentIds;

  @override
  int get hashCode => equipmentIds.hashCode;

  factory EquipmentPreferenceRequest.fromJson(Map<String, dynamic> json) =>
      _$EquipmentPreferenceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentPreferenceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
