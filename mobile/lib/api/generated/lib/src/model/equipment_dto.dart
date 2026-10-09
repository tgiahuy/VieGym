//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'equipment_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EquipmentDto {
  /// Returns a new [EquipmentDto] instance.
  EquipmentDto({this.id, this.code, this.name, this.description});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentDto &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.description == description;

  @override
  int get hashCode =>
      id.hashCode + code.hashCode + name.hashCode + description.hashCode;

  factory EquipmentDto.fromJson(Map<String, dynamic> json) =>
      _$EquipmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
