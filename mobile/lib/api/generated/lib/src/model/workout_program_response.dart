//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_day_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_program_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutProgramResponse {
  /// Returns a new [WorkoutProgramResponse] instance.
  WorkoutProgramResponse({
    this.id,

    this.name,

    this.programType,

    this.description,

    this.status,

    this.days,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'programType', required: false, includeIfNull: false)
  final String? programType;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'days', required: false, includeIfNull: false)
  final List<WorkoutDayResponse>? days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutProgramResponse &&
          other.id == id &&
          other.name == name &&
          other.programType == programType &&
          other.description == description &&
          other.status == status &&
          other.days == days;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      programType.hashCode +
      description.hashCode +
      status.hashCode +
      days.hashCode;

  factory WorkoutProgramResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgramResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProgramResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
