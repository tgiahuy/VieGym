//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discard_session_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DiscardSessionRequest {
  /// Returns a new [DiscardSessionRequest] instance.
  DiscardSessionRequest({this.reason});

  @JsonKey(name: r'reason', required: false, includeIfNull: false)
  final String? reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscardSessionRequest && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  factory DiscardSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$DiscardSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DiscardSessionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
