//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resume_session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResumeSessionResponse {
  /// Returns a new [ResumeSessionResponse] instance.
  ResumeSessionResponse({this.id, this.status, this.totalPausedSeconds});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'totalPausedSeconds', required: false, includeIfNull: false)
  final int? totalPausedSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeSessionResponse &&
          other.id == id &&
          other.status == status &&
          other.totalPausedSeconds == totalPausedSeconds;

  @override
  int get hashCode =>
      id.hashCode + status.hashCode + totalPausedSeconds.hashCode;

  factory ResumeSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$ResumeSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
