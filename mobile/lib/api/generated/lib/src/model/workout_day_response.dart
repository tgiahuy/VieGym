//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_exercise_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_day_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutDayResponse {
  /// Returns a new [WorkoutDayResponse] instance.
  WorkoutDayResponse({
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
  final List<WorkoutExerciseResponse>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDayResponse &&
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

  factory WorkoutDayResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDayResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutDayResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
