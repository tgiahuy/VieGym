//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/schedule_proposal_item_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_proposal_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ScheduleProposalResponse {
  /// Returns a new [ScheduleProposalResponse] instance.
  ScheduleProposalResponse({
    this.id,

    this.sourceType,

    this.scope,

    this.sourceId,

    this.sourceVersion,

    this.status,

    this.expiresAt,

    this.appliedAt,

    this.items,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'sourceType', required: false, includeIfNull: false)
  final String? sourceType;

  @JsonKey(name: r'scope', required: false, includeIfNull: false)
  final String? scope;

  @JsonKey(name: r'sourceId', required: false, includeIfNull: false)
  final int? sourceId;

  @JsonKey(name: r'sourceVersion', required: false, includeIfNull: false)
  final int? sourceVersion;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'expiresAt', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @JsonKey(name: r'appliedAt', required: false, includeIfNull: false)
  final DateTime? appliedAt;

  @JsonKey(name: r'items', required: false, includeIfNull: false)
  final List<ScheduleProposalItemResponse>? items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleProposalResponse &&
          other.id == id &&
          other.sourceType == sourceType &&
          other.scope == scope &&
          other.sourceId == sourceId &&
          other.sourceVersion == sourceVersion &&
          other.status == status &&
          other.expiresAt == expiresAt &&
          other.appliedAt == appliedAt &&
          other.items == items;

  @override
  int get hashCode =>
      id.hashCode +
      sourceType.hashCode +
      scope.hashCode +
      sourceId.hashCode +
      sourceVersion.hashCode +
      status.hashCode +
      expiresAt.hashCode +
      appliedAt.hashCode +
      items.hashCode;

  factory ScheduleProposalResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleProposalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleProposalResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
