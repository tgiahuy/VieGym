//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_completion.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutCompletion {
  /// Returns a new [WorkoutCompletion] instance.
  WorkoutCompletion({
    this.windowFrom,

    this.windowTo,

    this.scheduledEligible,

    this.completedEligible,

    this.rate,
  });

  @JsonKey(name: r'windowFrom', required: false, includeIfNull: false)
  final DateTime? windowFrom;

  @JsonKey(name: r'windowTo', required: false, includeIfNull: false)
  final DateTime? windowTo;

  @JsonKey(name: r'scheduledEligible', required: false, includeIfNull: false)
  final int? scheduledEligible;

  @JsonKey(name: r'completedEligible', required: false, includeIfNull: false)
  final int? completedEligible;

  @JsonKey(name: r'rate', required: false, includeIfNull: false)
  final num? rate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutCompletion &&
          other.windowFrom == windowFrom &&
          other.windowTo == windowTo &&
          other.scheduledEligible == scheduledEligible &&
          other.completedEligible == completedEligible &&
          other.rate == rate;

  @override
  int get hashCode =>
      windowFrom.hashCode +
      windowTo.hashCode +
      scheduledEligible.hashCode +
      completedEligible.hashCode +
      rate.hashCode;

  factory WorkoutCompletion.fromJson(Map<String, dynamic> json) =>
      _$WorkoutCompletionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutCompletionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
