//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/health_profile_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_response_health_profile_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiResponseHealthProfileResponse {
  /// Returns a new [ApiResponseHealthProfileResponse] instance.
  ApiResponseHealthProfileResponse({this.success, this.message, this.data});

  @JsonKey(name: r'success', required: false, includeIfNull: false)
  final bool? success;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final HealthProfileResponse? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponseHealthProfileResponse &&
          other.success == success &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => success.hashCode + message.hashCode + data.hashCode;

  factory ApiResponseHealthProfileResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ApiResponseHealthProfileResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ApiResponseHealthProfileResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
