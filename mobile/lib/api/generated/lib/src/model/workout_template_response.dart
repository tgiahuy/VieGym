//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_template_day_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_template_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutTemplateResponse {
  /// Returns a new [WorkoutTemplateResponse] instance.
  WorkoutTemplateResponse({
    this.id,

    this.name,

    this.programType,

    this.description,

    this.difficulty,

    this.goal,

    this.status,

    this.version,

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

  @JsonKey(name: r'difficulty', required: false, includeIfNull: false)
  final String? difficulty;

  @JsonKey(name: r'goal', required: false, includeIfNull: false)
  final String? goal;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'version', required: false, includeIfNull: false)
  final int? version;

  @JsonKey(name: r'days', required: false, includeIfNull: false)
  final List<WorkoutTemplateDayResponse>? days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplateResponse &&
          other.id == id &&
          other.name == name &&
          other.programType == programType &&
          other.description == description &&
          other.difficulty == difficulty &&
          other.goal == goal &&
          other.status == status &&
          other.version == version &&
          other.days == days;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      programType.hashCode +
      description.hashCode +
      difficulty.hashCode +
      goal.hashCode +
      status.hashCode +
      version.hashCode +
      days.hashCode;

  factory WorkoutTemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutTemplateResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
