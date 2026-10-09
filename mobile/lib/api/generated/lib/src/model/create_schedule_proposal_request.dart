//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/schedule_proposal_item_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_schedule_proposal_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateScheduleProposalRequest {
  /// Returns a new [CreateScheduleProposalRequest] instance.
  CreateScheduleProposalRequest({
    this.sourceType,

    this.scope,

    this.sourceId,

    this.sourceDayId,

    this.targetDates,

    this.scheduledTime,

    this.items,
  });

  @JsonKey(name: r'sourceType', required: false, includeIfNull: false)
  final String? sourceType;

  @JsonKey(name: r'scope', required: false, includeIfNull: false)
  final String? scope;

  @JsonKey(name: r'sourceId', required: false, includeIfNull: false)
  final int? sourceId;

  @JsonKey(name: r'sourceDayId', required: false, includeIfNull: false)
  final int? sourceDayId;

  @JsonKey(name: r'targetDates', required: false, includeIfNull: false)
  final List<DateTime>? targetDates;

  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final String? scheduledTime;

  @JsonKey(name: r'items', required: false, includeIfNull: false)
  final List<ScheduleProposalItemRequest>? items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateScheduleProposalRequest &&
          other.sourceType == sourceType &&
          other.scope == scope &&
          other.sourceId == sourceId &&
          other.sourceDayId == sourceDayId &&
          other.targetDates == targetDates &&
          other.scheduledTime == scheduledTime &&
          other.items == items;

  @override
  int get hashCode =>
      sourceType.hashCode +
      scope.hashCode +
      sourceId.hashCode +
      sourceDayId.hashCode +
      targetDates.hashCode +
      scheduledTime.hashCode +
      items.hashCode;

  factory CreateScheduleProposalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleProposalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateScheduleProposalRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
