//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/personal_record_dto.dart';
import 'package:viegym_api/src/model/workout_exercise_log_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_log_detail_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutLogDetailDto {
  /// Returns a new [WorkoutLogDetailDto] instance.
  WorkoutLogDetailDto({
    this.id,

    this.workoutSessionId,

    this.workoutScheduleId,

    this.title,

    this.startedAt,

    this.completedAt,

    this.durationSeconds,

    this.totalVolumeKg,

    this.note,

    this.exercises,

    this.personalRecords,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'workoutSessionId', required: false, includeIfNull: false)
  final int? workoutSessionId;

  @JsonKey(name: r'workoutScheduleId', required: false, includeIfNull: false)
  final int? workoutScheduleId;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'startedAt', required: false, includeIfNull: false)
  final DateTime? startedAt;

  @JsonKey(name: r'completedAt', required: false, includeIfNull: false)
  final DateTime? completedAt;

  @JsonKey(name: r'durationSeconds', required: false, includeIfNull: false)
  final int? durationSeconds;

  @JsonKey(name: r'totalVolumeKg', required: false, includeIfNull: false)
  final double? totalVolumeKg;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'exercises', required: false, includeIfNull: false)
  final List<WorkoutExerciseLogDto>? exercises;

  @JsonKey(name: r'personalRecords', required: false, includeIfNull: false)
  final List<PersonalRecordDto>? personalRecords;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogDetailDto &&
          other.id == id &&
          other.workoutSessionId == workoutSessionId &&
          other.workoutScheduleId == workoutScheduleId &&
          other.title == title &&
          other.startedAt == startedAt &&
          other.completedAt == completedAt &&
          other.durationSeconds == durationSeconds &&
          other.totalVolumeKg == totalVolumeKg &&
          other.note == note &&
          other.exercises == exercises &&
          other.personalRecords == personalRecords;

  @override
  int get hashCode =>
      id.hashCode +
      workoutSessionId.hashCode +
      workoutScheduleId.hashCode +
      title.hashCode +
      startedAt.hashCode +
      completedAt.hashCode +
      durationSeconds.hashCode +
      totalVolumeKg.hashCode +
      note.hashCode +
      exercises.hashCode +
      personalRecords.hashCode;

  factory WorkoutLogDetailDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutLogDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
