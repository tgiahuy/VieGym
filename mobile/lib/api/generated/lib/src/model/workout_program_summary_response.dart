//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_program_summary_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutProgramSummaryResponse {
  /// Returns a new [WorkoutProgramSummaryResponse] instance.
  WorkoutProgramSummaryResponse({
    this.id,

    this.name,

    this.programType,

    this.description,

    this.status,

    this.totalDays,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'programType', required: false, includeIfNull: false)
  final String? programType;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'totalDays', required: false, includeIfNull: false)
  final int? totalDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutProgramSummaryResponse &&
          other.id == id &&
          other.name == name &&
          other.programType == programType &&
          other.description == description &&
          other.status == status &&
          other.totalDays == totalDays;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      programType.hashCode +
      description.hashCode +
      status.hashCode +
      totalDays.hashCode;

  factory WorkoutProgramSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgramSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutProgramSummaryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
