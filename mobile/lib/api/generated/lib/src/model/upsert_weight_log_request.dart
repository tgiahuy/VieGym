//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_weight_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertWeightLogRequest {
  /// Returns a new [UpsertWeightLogRequest] instance.
  UpsertWeightLogRequest({required this.weightKg, this.note});

  // minimum: 0.01
  // maximum: 9999.99
  @JsonKey(name: r'weightKg', required: true, includeIfNull: false)
  final num weightKg;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertWeightLogRequest &&
          other.weightKg == weightKg &&
          other.note == note;

  @override
  int get hashCode => weightKg.hashCode + note.hashCode;

  factory UpsertWeightLogRequest.fromJson(Map<String, dynamic> json) =>
      _$UpsertWeightLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertWeightLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
