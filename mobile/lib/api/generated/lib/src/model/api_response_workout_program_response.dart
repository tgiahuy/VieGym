//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_program_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_response_workout_program_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiResponseWorkoutProgramResponse {
  /// Returns a new [ApiResponseWorkoutProgramResponse] instance.
  ApiResponseWorkoutProgramResponse({this.success, this.message, this.data});

  @JsonKey(name: r'success', required: false, includeIfNull: false)
  final bool? success;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final WorkoutProgramResponse? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponseWorkoutProgramResponse &&
          other.success == success &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => success.hashCode + message.hashCode + data.hashCode;

  factory ApiResponseWorkoutProgramResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiResponseWorkoutProgramResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ApiResponseWorkoutProgramResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
