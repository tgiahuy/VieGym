//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_schedule_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apply_schedule_proposal_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApplyScheduleProposalResponse {
  /// Returns a new [ApplyScheduleProposalResponse] instance.
  ApplyScheduleProposalResponse({this.proposalId, this.status, this.schedules});

  @JsonKey(name: r'proposalId', required: false, includeIfNull: false)
  final int? proposalId;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'schedules', required: false, includeIfNull: false)
  final List<WorkoutScheduleResponse>? schedules;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplyScheduleProposalResponse &&
          other.proposalId == proposalId &&
          other.status == status &&
          other.schedules == schedules;

  @override
  int get hashCode =>
      proposalId.hashCode + status.hashCode + schedules.hashCode;

  factory ApplyScheduleProposalResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplyScheduleProposalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyScheduleProposalResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
