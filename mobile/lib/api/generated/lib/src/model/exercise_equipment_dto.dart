//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_equipment_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExerciseEquipmentDto {
  /// Returns a new [ExerciseEquipmentDto] instance.
  ExerciseEquipmentDto({this.id, this.code, this.name, this.required_});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'required', required: false, includeIfNull: false)
  final bool? required_;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseEquipmentDto &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.required_ == required_;

  @override
  int get hashCode =>
      id.hashCode + code.hashCode + name.hashCode + required_.hashCode;

  factory ExerciseEquipmentDto.fromJson(Map<String, dynamic> json) =>
      _$ExerciseEquipmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseEquipmentDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
