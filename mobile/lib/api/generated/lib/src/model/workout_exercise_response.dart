//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_exercise_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutExerciseResponse {
  /// Returns a new [WorkoutExerciseResponse] instance.
  WorkoutExerciseResponse({
    this.id,

    this.exerciseId,

    this.exerciseName,

    this.exerciseSlug,

    this.hidden,

    this.sortOrder,

    this.targetSets,

    this.targetRepsMin,

    this.targetRepsMax,

    this.targetDurationSeconds,

    this.restSeconds,

    this.note,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'exerciseId', required: false, includeIfNull: false)
  final int? exerciseId;

  @JsonKey(name: r'exerciseName', required: false, includeIfNull: false)
  final String? exerciseName;

  @JsonKey(name: r'exerciseSlug', required: false, includeIfNull: false)
  final String? exerciseSlug;

  @JsonKey(name: r'hidden', required: false, includeIfNull: false)
  final bool? hidden;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'targetSets', required: false, includeIfNull: false)
  final int? targetSets;

  @JsonKey(name: r'targetRepsMin', required: false, includeIfNull: false)
  final int? targetRepsMin;

  @JsonKey(name: r'targetRepsMax', required: false, includeIfNull: false)
  final int? targetRepsMax;

  @JsonKey(
    name: r'targetDurationSeconds',
    required: false,
    includeIfNull: false,
  )
  final int? targetDurationSeconds;

  @JsonKey(name: r'restSeconds', required: false, includeIfNull: false)
  final int? restSeconds;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciseResponse &&
          other.id == id &&
          other.exerciseId == exerciseId &&
          other.exerciseName == exerciseName &&
          other.exerciseSlug == exerciseSlug &&
          other.hidden == hidden &&
          other.sortOrder == sortOrder &&
          other.targetSets == targetSets &&
          other.targetRepsMin == targetRepsMin &&
          other.targetRepsMax == targetRepsMax &&
          other.targetDurationSeconds == targetDurationSeconds &&
          other.restSeconds == restSeconds &&
          other.note == note;

  @override
  int get hashCode =>
      id.hashCode +
      exerciseId.hashCode +
      exerciseName.hashCode +
      exerciseSlug.hashCode +
      hidden.hashCode +
      sortOrder.hashCode +
      targetSets.hashCode +
      targetRepsMin.hashCode +
      targetRepsMax.hashCode +
      targetDurationSeconds.hashCode +
      restSeconds.hashCode +
      note.hashCode;

  factory WorkoutExerciseResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutExerciseResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
