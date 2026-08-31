//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_response_void.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiResponseVoid {
  /// Returns a new [ApiResponseVoid] instance.
  ApiResponseVoid({this.success, this.message, this.data});

  @JsonKey(name: r'success', required: false, includeIfNull: false)
  final bool? success;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final Object? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponseVoid &&
          other.success == success &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode =>
      success.hashCode + message.hashCode + (data == null ? 0 : data.hashCode);

  factory ApiResponseVoid.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseVoidFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseVoidToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
