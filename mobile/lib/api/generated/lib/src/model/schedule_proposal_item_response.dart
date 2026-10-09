//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/schedule_exercise_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_proposal_item_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ScheduleProposalItemResponse {
  /// Returns a new [ScheduleProposalItemResponse] instance.
  ScheduleProposalItemResponse({
    this.id,

    this.sortOrder,

    this.sourceDayId,

    this.scheduledDate,

    this.scheduledTime,

    this.title,

    this.appliedScheduleId,

    this.exercises,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'sourceDayId', required: false, includeIfNull: false)
  final int? sourceDayId;

  @JsonKey(name: r'scheduledDate', required: false, includeIfNull: false)
  final DateTime? scheduledDate;

  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final String? scheduledTime;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'appliedScheduleId', required: false, includeIfNull: false)
  final int? appliedScheduleId;

  @JsonKey(name: r'exercises', required: false, includeIfNull: false)
  final List<ScheduleExercisePlan>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleProposalItemResponse &&
          other.id == id &&
          other.sortOrder == sortOrder &&
          other.sourceDayId == sourceDayId &&
          other.scheduledDate == scheduledDate &&
          other.scheduledTime == scheduledTime &&
          other.title == title &&
          other.appliedScheduleId == appliedScheduleId &&
          other.exercises == exercises;

  @override
  int get hashCode =>
      id.hashCode +
      sortOrder.hashCode +
      sourceDayId.hashCode +
      scheduledDate.hashCode +
      scheduledTime.hashCode +
      title.hashCode +
      appliedScheduleId.hashCode +
      exercises.hashCode;

  factory ScheduleProposalItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleProposalItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleProposalItemResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
