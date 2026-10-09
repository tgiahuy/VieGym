//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_exercise_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_day_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutDayRequest {
  /// Returns a new [WorkoutDayRequest] instance.
  WorkoutDayRequest({
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
  final List<WorkoutExerciseRequest>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDayRequest &&
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

  factory WorkoutDayRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDayRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutDayRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
