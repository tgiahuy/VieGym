//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_schedule_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutScheduleRequest {
  /// Returns a new [WorkoutScheduleRequest] instance.
  WorkoutScheduleRequest({
    this.workoutProgramId,

    this.workoutDayId,

    this.scheduledDate,

    this.scheduledTime,

    this.title,
  });

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutScheduleRequest &&
          other.workoutProgramId == workoutProgramId &&
          other.workoutDayId == workoutDayId &&
          other.scheduledDate == scheduledDate &&
          other.scheduledTime == scheduledTime &&
          other.title == title;

  @override
  int get hashCode =>
      workoutProgramId.hashCode +
      workoutDayId.hashCode +
      scheduledDate.hashCode +
      scheduledTime.hashCode +
      title.hashCode;

  factory WorkoutScheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$WorkoutScheduleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutScheduleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
