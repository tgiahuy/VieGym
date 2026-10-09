//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_template_day_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_template_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutTemplateRequest {
  /// Returns a new [WorkoutTemplateRequest] instance.
  WorkoutTemplateRequest({
    this.name,

    this.programType,

    this.description,

    this.difficulty,

    this.goal,

    this.status,

    this.days,
  });

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'programType', required: false, includeIfNull: false)
  final String? programType;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'difficulty', required: false, includeIfNull: false)
  final String? difficulty;

  @JsonKey(name: r'goal', required: false, includeIfNull: false)
  final String? goal;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'days', required: false, includeIfNull: false)
  final List<WorkoutTemplateDayRequest>? days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplateRequest &&
          other.name == name &&
          other.programType == programType &&
          other.description == description &&
          other.difficulty == difficulty &&
          other.goal == goal &&
          other.status == status &&
          other.days == days;

  @override
  int get hashCode =>
      name.hashCode +
      programType.hashCode +
      description.hashCode +
      difficulty.hashCode +
      goal.hashCode +
      status.hashCode +
      days.hashCode;

  factory WorkoutTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutTemplateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
