//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/finish_set_log_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finish_exercise_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FinishExerciseLogRequest {
  /// Returns a new [FinishExerciseLogRequest] instance.
  FinishExerciseLogRequest({
    this.exerciseId,

    this.sortOrder,

    this.durationSeconds,

    this.completed,

    this.sets,
  });

  @JsonKey(name: r'exerciseId', required: false, includeIfNull: false)
  final int? exerciseId;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'durationSeconds', required: false, includeIfNull: false)
  final int? durationSeconds;

  @JsonKey(name: r'completed', required: false, includeIfNull: false)
  final bool? completed;

  @JsonKey(name: r'sets', required: false, includeIfNull: false)
  final List<FinishSetLogRequest>? sets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinishExerciseLogRequest &&
          other.exerciseId == exerciseId &&
          other.sortOrder == sortOrder &&
          other.durationSeconds == durationSeconds &&
          other.completed == completed &&
          other.sets == sets;

  @override
  int get hashCode =>
      exerciseId.hashCode +
      sortOrder.hashCode +
      durationSeconds.hashCode +
      completed.hashCode +
      sets.hashCode;

  factory FinishExerciseLogRequest.fromJson(Map<String, dynamic> json) =>
      _$FinishExerciseLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FinishExerciseLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
