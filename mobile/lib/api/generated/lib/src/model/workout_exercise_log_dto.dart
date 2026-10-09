//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_set_log_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_exercise_log_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutExerciseLogDto {
  /// Returns a new [WorkoutExerciseLogDto] instance.
  WorkoutExerciseLogDto({
    this.id,

    this.exerciseId,

    this.exerciseName,

    this.sortOrder,

    this.durationSeconds,

    this.exerciseVolumeKg,

    this.completed,

    this.sets,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'exerciseId', required: false, includeIfNull: false)
  final int? exerciseId;

  @JsonKey(name: r'exerciseName', required: false, includeIfNull: false)
  final String? exerciseName;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'durationSeconds', required: false, includeIfNull: false)
  final int? durationSeconds;

  @JsonKey(name: r'exerciseVolumeKg', required: false, includeIfNull: false)
  final double? exerciseVolumeKg;

  @JsonKey(name: r'completed', required: false, includeIfNull: false)
  final bool? completed;

  @JsonKey(name: r'sets', required: false, includeIfNull: false)
  final List<WorkoutSetLogDto>? sets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciseLogDto &&
          other.id == id &&
          other.exerciseId == exerciseId &&
          other.exerciseName == exerciseName &&
          other.sortOrder == sortOrder &&
          other.durationSeconds == durationSeconds &&
          other.exerciseVolumeKg == exerciseVolumeKg &&
          other.completed == completed &&
          other.sets == sets;

  @override
  int get hashCode =>
      id.hashCode +
      exerciseId.hashCode +
      exerciseName.hashCode +
      sortOrder.hashCode +
      durationSeconds.hashCode +
      exerciseVolumeKg.hashCode +
      completed.hashCode +
      sets.hashCode;

  factory WorkoutExerciseLogDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutExerciseLogDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
