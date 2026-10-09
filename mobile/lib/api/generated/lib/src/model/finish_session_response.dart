//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/personal_record_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finish_session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FinishSessionResponse {
  /// Returns a new [FinishSessionResponse] instance.
  FinishSessionResponse({
    this.workoutLogId,

    this.workoutSessionId,

    this.durationSeconds,

    this.totalVolumeKg,

    this.newPersonalRecords,
  });

  @JsonKey(name: r'workoutLogId', required: false, includeIfNull: false)
  final int? workoutLogId;

  @JsonKey(name: r'workoutSessionId', required: false, includeIfNull: false)
  final int? workoutSessionId;

  @JsonKey(name: r'durationSeconds', required: false, includeIfNull: false)
  final int? durationSeconds;

  @JsonKey(name: r'totalVolumeKg', required: false, includeIfNull: false)
  final double? totalVolumeKg;

  @JsonKey(name: r'newPersonalRecords', required: false, includeIfNull: false)
  final List<PersonalRecordDto>? newPersonalRecords;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinishSessionResponse &&
          other.workoutLogId == workoutLogId &&
          other.workoutSessionId == workoutSessionId &&
          other.durationSeconds == durationSeconds &&
          other.totalVolumeKg == totalVolumeKg &&
          other.newPersonalRecords == newPersonalRecords;

  @override
  int get hashCode =>
      workoutLogId.hashCode +
      workoutSessionId.hashCode +
      durationSeconds.hashCode +
      totalVolumeKg.hashCode +
      newPersonalRecords.hashCode;

  factory FinishSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$FinishSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FinishSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
