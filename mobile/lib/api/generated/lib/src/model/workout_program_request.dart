//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_day_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_program_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutProgramRequest {
  /// Returns a new [WorkoutProgramRequest] instance.
  WorkoutProgramRequest({
    this.name,

    this.programType,

    this.description,

    this.status,

    this.days,
  });

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'programType', required: false, includeIfNull: false)
  final String? programType;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'days', required: false, includeIfNull: false)
  final List<WorkoutDayRequest>? days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutProgramRequest &&
          other.name == name &&
          other.programType == programType &&
          other.description == description &&
          other.status == status &&
          other.days == days;

  @override
  int get hashCode =>
      name.hashCode +
      programType.hashCode +
      description.hashCode +
      status.hashCode +
      days.hashCode;

  factory WorkoutProgramRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgramRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProgramRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
