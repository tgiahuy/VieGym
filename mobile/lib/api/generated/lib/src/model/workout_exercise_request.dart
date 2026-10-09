//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_exercise_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutExerciseRequest {
  /// Returns a new [WorkoutExerciseRequest] instance.
  WorkoutExerciseRequest({
    this.id,

    this.exerciseId,

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
      other is WorkoutExerciseRequest &&
          other.id == id &&
          other.exerciseId == exerciseId &&
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
      sortOrder.hashCode +
      targetSets.hashCode +
      targetRepsMin.hashCode +
      targetRepsMax.hashCode +
      targetDurationSeconds.hashCode +
      restSeconds.hashCode +
      note.hashCode;

  factory WorkoutExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutExerciseRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
