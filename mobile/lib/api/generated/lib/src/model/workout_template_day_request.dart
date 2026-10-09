//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/schedule_exercise_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_template_day_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutTemplateDayRequest {
  /// Returns a new [WorkoutTemplateDayRequest] instance.
  WorkoutTemplateDayRequest({
    this.dayNumber,

    this.name,

    this.note,

    this.exercises,
  });

  @JsonKey(name: r'dayNumber', required: false, includeIfNull: false)
  final int? dayNumber;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'exercises', required: false, includeIfNull: false)
  final List<ScheduleExercisePlan>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplateDayRequest &&
          other.dayNumber == dayNumber &&
          other.name == name &&
          other.note == note &&
          other.exercises == exercises;

  @override
  int get hashCode =>
      dayNumber.hashCode + name.hashCode + note.hashCode + exercises.hashCode;

  factory WorkoutTemplateDayRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateDayRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutTemplateDayRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
