//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finish_set_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FinishSetLogRequest {
  /// Returns a new [FinishSetLogRequest] instance.
  FinishSetLogRequest({
    this.setNumber,

    this.reps,

    this.weightKg,

    this.durationSeconds,

    this.rpe,

    this.completed,
  });

  @JsonKey(name: r'setNumber', required: false, includeIfNull: false)
  final int? setNumber;

  @JsonKey(name: r'reps', required: false, includeIfNull: false)
  final int? reps;

  @JsonKey(name: r'weightKg', required: false, includeIfNull: false)
  final double? weightKg;

  @JsonKey(name: r'durationSeconds', required: false, includeIfNull: false)
  final int? durationSeconds;

  @JsonKey(name: r'rpe', required: false, includeIfNull: false)
  final double? rpe;

  @JsonKey(name: r'completed', required: false, includeIfNull: false)
  final bool? completed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinishSetLogRequest &&
          other.setNumber == setNumber &&
          other.reps == reps &&
          other.weightKg == weightKg &&
          other.durationSeconds == durationSeconds &&
          other.rpe == rpe &&
          other.completed == completed;

  @override
  int get hashCode =>
      setNumber.hashCode +
      reps.hashCode +
      weightKg.hashCode +
      durationSeconds.hashCode +
      rpe.hashCode +
      completed.hashCode;

  factory FinishSetLogRequest.fromJson(Map<String, dynamic> json) =>
      _$FinishSetLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FinishSetLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
