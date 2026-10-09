//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_exercise_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartSessionResponse {
  /// Returns a new [StartSessionResponse] instance.
  StartSessionResponse({
    this.id,

    this.workoutScheduleId,

    this.status,

    this.startedAt,

    this.totalPausedSeconds,

    this.exercises,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'workoutScheduleId', required: false, includeIfNull: false)
  final int? workoutScheduleId;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'startedAt', required: false, includeIfNull: false)
  final DateTime? startedAt;

  @JsonKey(name: r'totalPausedSeconds', required: false, includeIfNull: false)
  final int? totalPausedSeconds;

  @JsonKey(name: r'exercises', required: false, includeIfNull: false)
  final List<WorkoutExerciseResponse>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartSessionResponse &&
          other.id == id &&
          other.workoutScheduleId == workoutScheduleId &&
          other.status == status &&
          other.startedAt == startedAt &&
          other.totalPausedSeconds == totalPausedSeconds &&
          other.exercises == exercises;

  @override
  int get hashCode =>
      id.hashCode +
      workoutScheduleId.hashCode +
      status.hashCode +
      startedAt.hashCode +
      totalPausedSeconds.hashCode +
      exercises.hashCode;

  factory StartSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$StartSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StartSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
