//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_log_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutLogSummaryDto {
  /// Returns a new [WorkoutLogSummaryDto] instance.
  WorkoutLogSummaryDto({
    this.id,

    this.workoutSessionId,

    this.workoutScheduleId,

    this.title,

    this.startedAt,

    this.completedAt,

    this.durationSeconds,

    this.totalVolumeKg,

    this.totalExercises,

    this.prCount,
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

  @JsonKey(name: r'totalExercises', required: false, includeIfNull: false)
  final int? totalExercises;

  @JsonKey(name: r'prCount', required: false, includeIfNull: false)
  final int? prCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogSummaryDto &&
          other.id == id &&
          other.workoutSessionId == workoutSessionId &&
          other.workoutScheduleId == workoutScheduleId &&
          other.title == title &&
          other.startedAt == startedAt &&
          other.completedAt == completedAt &&
          other.durationSeconds == durationSeconds &&
          other.totalVolumeKg == totalVolumeKg &&
          other.totalExercises == totalExercises &&
          other.prCount == prCount;

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
      totalExercises.hashCode +
      prCount.hashCode;

  factory WorkoutLogSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutLogSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
