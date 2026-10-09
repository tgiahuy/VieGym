//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/finish_exercise_log_request.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finish_session_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FinishSessionRequest {
  /// Returns a new [FinishSessionRequest] instance.
  FinishSessionRequest({this.note, this.exercises});

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'exercises', required: false, includeIfNull: false)
  final List<FinishExerciseLogRequest>? exercises;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinishSessionRequest &&
          other.note == note &&
          other.exercises == exercises;

  @override
  int get hashCode => note.hashCode + exercises.hashCode;

  factory FinishSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$FinishSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FinishSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
