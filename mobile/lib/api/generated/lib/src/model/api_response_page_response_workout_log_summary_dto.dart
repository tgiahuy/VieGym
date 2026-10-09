//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/page_response_workout_log_summary_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_response_page_response_workout_log_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiResponsePageResponseWorkoutLogSummaryDto {
  /// Returns a new [ApiResponsePageResponseWorkoutLogSummaryDto] instance.
  ApiResponsePageResponseWorkoutLogSummaryDto({
    this.success,

    this.message,

    this.data,
  });

  @JsonKey(name: r'success', required: false, includeIfNull: false)
  final bool? success;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final PageResponseWorkoutLogSummaryDto? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponsePageResponseWorkoutLogSummaryDto &&
          other.success == success &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => success.hashCode + message.hashCode + data.hashCode;

  factory ApiResponsePageResponseWorkoutLogSummaryDto.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiResponsePageResponseWorkoutLogSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ApiResponsePageResponseWorkoutLogSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
