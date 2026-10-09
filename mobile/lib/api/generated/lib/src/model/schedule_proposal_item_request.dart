//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/schedule_exercise_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_proposal_item_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ScheduleProposalItemRequest {
  /// Returns a new [ScheduleProposalItemRequest] instance.
  ScheduleProposalItemRequest({
    this.scheduledDate,

    this.scheduledTime,

    this.title,

    this.exercises,
  });

  @JsonKey(name: r'scheduledDate', required: false, includeIfNull: false)
  final DateTime? scheduledDate;

  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final String? scheduledTime;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'exercises', required: false, includeIfNull: false)
  final List<ScheduleExercisePlan>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleProposalItemRequest &&
          other.scheduledDate == scheduledDate &&
          other.scheduledTime == scheduledTime &&
          other.title == title &&
          other.exercises == exercises;

  @override
  int get hashCode =>
      scheduledDate.hashCode +
      scheduledTime.hashCode +
      title.hashCode +
      exercises.hashCode;

  factory ScheduleProposalItemRequest.fromJson(Map<String, dynamic> json) =>
      _$ScheduleProposalItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleProposalItemRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
