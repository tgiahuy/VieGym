//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pause_session_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PauseSessionResponse {
  /// Returns a new [PauseSessionResponse] instance.
  PauseSessionResponse({
    this.id,

    this.status,

    this.pausedAt,

    this.totalPausedSeconds,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final String? status;

  @JsonKey(name: r'pausedAt', required: false, includeIfNull: false)
  final DateTime? pausedAt;

  @JsonKey(name: r'totalPausedSeconds', required: false, includeIfNull: false)
  final int? totalPausedSeconds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PauseSessionResponse &&
          other.id == id &&
          other.status == status &&
          other.pausedAt == pausedAt &&
          other.totalPausedSeconds == totalPausedSeconds;

  @override
  int get hashCode =>
      id.hashCode +
      status.hashCode +
      pausedAt.hashCode +
      totalPausedSeconds.hashCode;

  factory PauseSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$PauseSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PauseSessionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
