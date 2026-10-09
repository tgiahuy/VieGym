//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_muscle_group_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExerciseMuscleGroupDto {
  /// Returns a new [ExerciseMuscleGroupDto] instance.
  ExerciseMuscleGroupDto({this.id, this.code, this.name, this.role});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'role', required: false, includeIfNull: false)
  final String? role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseMuscleGroupDto &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.role == role;

  @override
  int get hashCode =>
      id.hashCode + code.hashCode + name.hashCode + role.hashCode;

  factory ExerciseMuscleGroupDto.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMuscleGroupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseMuscleGroupDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
