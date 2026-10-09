//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_schedule_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutScheduleResponse {
  /// Returns a new [WorkoutScheduleResponse] instance.
  WorkoutScheduleResponse({
    this.id,

    this.workoutProgramId,

    this.workoutDayId,

    this.scheduledDate,

    this.scheduledTime,

    this.title,

    this.status,

    this.cancelReason,

    this.completedAt,

    this.activeSessionId,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'workoutProgramId', required: false, includeIfNull: false)
  final int? workoutProgramId;

  @JsonKey(name: r'workoutDayId', required: false, includeIfNull: false)
  final int? workoutDayId;

  @JsonKey(name: r'scheduledDate', required: false, includeIfNull: false)
  final DateTime? scheduledDate;

  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final String? scheduledTime;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'cancelReason', required: false, includeIfNull: false)
  final String? cancelReason;

  @JsonKey(name: r'completedAt', required: false, includeIfNull: false)
  final DateTime? completedAt;

  @JsonKey(name: r'activeSessionId', required: false, includeIfNull: false)
  final int? activeSessionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutScheduleResponse &&
          other.id == id &&
          other.workoutProgramId == workoutProgramId &&
          other.workoutDayId == workoutDayId &&
          other.scheduledDate == scheduledDate &&
          other.scheduledTime == scheduledTime &&
          other.title == title &&
          other.status == status &&
          other.cancelReason == cancelReason &&
          other.completedAt == completedAt &&
          other.activeSessionId == activeSessionId;

  @override
  int get hashCode =>
      id.hashCode +
      workoutProgramId.hashCode +
      workoutDayId.hashCode +
      scheduledDate.hashCode +
      scheduledTime.hashCode +
      title.hashCode +
      status.hashCode +
      cancelReason.hashCode +
      completedAt.hashCode +
      activeSessionId.hashCode;

  factory WorkoutScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutScheduleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutScheduleResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
