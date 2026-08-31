//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/session_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_response_session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiResponseSessionResponse {
  /// Returns a new [ApiResponseSessionResponse] instance.
  ApiResponseSessionResponse({this.success, this.message, this.data});

  @JsonKey(name: r'success', required: false, includeIfNull: false)
  final bool? success;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final SessionResponse? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponseSessionResponse &&
          other.success == success &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => success.hashCode + message.hashCode + data.hashCode;

  factory ApiResponseSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
