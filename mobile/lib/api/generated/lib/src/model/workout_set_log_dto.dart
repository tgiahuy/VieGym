//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_set_log_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutSetLogDto {
  /// Returns a new [WorkoutSetLogDto] instance.
  WorkoutSetLogDto({
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
      other is WorkoutSetLogDto &&
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

  factory WorkoutSetLogDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSetLogDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
