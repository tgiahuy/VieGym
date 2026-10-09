//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'personal_record_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PersonalRecordDto {
  /// Returns a new [PersonalRecordDto] instance.
  PersonalRecordDto({
    this.id,

    this.exerciseId,

    this.exerciseName,

    this.recordType,

    this.value,

    this.achievedAt,

    this.workoutLogId,

    this.previousValue,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'exerciseId', required: false, includeIfNull: false)
  final int? exerciseId;

  @JsonKey(name: r'exerciseName', required: false, includeIfNull: false)
  final String? exerciseName;

  @JsonKey(name: r'recordType', required: false, includeIfNull: false)
  final String? recordType;

  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final double? value;

  @JsonKey(name: r'achievedAt', required: false, includeIfNull: false)
  final DateTime? achievedAt;

  @JsonKey(name: r'workoutLogId', required: false, includeIfNull: false)
  final int? workoutLogId;

  @JsonKey(name: r'previousValue', required: false, includeIfNull: false)
  final double? previousValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordDto &&
          other.id == id &&
          other.exerciseId == exerciseId &&
          other.exerciseName == exerciseName &&
          other.recordType == recordType &&
          other.value == value &&
          other.achievedAt == achievedAt &&
          other.workoutLogId == workoutLogId &&
          other.previousValue == previousValue;

  @override
  int get hashCode =>
      id.hashCode +
      exerciseId.hashCode +
      exerciseName.hashCode +
      recordType.hashCode +
      value.hashCode +
      achievedAt.hashCode +
      workoutLogId.hashCode +
      previousValue.hashCode;

  factory PersonalRecordDto.fromJson(Map<String, dynamic> json) =>
      _$PersonalRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalRecordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
