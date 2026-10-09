//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/schedule_exercise_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_template_day_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutTemplateDayResponse {
  /// Returns a new [WorkoutTemplateDayResponse] instance.
  WorkoutTemplateDayResponse({
    this.id,

    this.dayNumber,

    this.name,

    this.note,

    this.exercises,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

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
      other is WorkoutTemplateDayResponse &&
          other.id == id &&
          other.dayNumber == dayNumber &&
          other.name == name &&
          other.note == note &&
          other.exercises == exercises;

  @override
  int get hashCode =>
      id.hashCode +
      dayNumber.hashCode +
      name.hashCode +
      note.hashCode +
      exercises.hashCode;

  factory WorkoutTemplateDayResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateDayResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutTemplateDayResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
