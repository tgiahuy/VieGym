//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_completion.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_section.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutSection {
  /// Returns a new [WorkoutSection] instance.
  WorkoutSection({this.today, this.next, this.completion});

  @JsonKey(name: r'today', required: false, includeIfNull: false)
  final List<Object>? today;

  @JsonKey(name: r'next', required: false, includeIfNull: false)
  final Object? next;

  @JsonKey(name: r'completion', required: false, includeIfNull: false)
  final WorkoutCompletion? completion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSection &&
          other.today == today &&
          other.next == next &&
          other.completion == completion;

  @override
  int get hashCode =>
      today.hashCode + (next == null ? 0 : next.hashCode) + completion.hashCode;

  factory WorkoutSection.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSectionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
