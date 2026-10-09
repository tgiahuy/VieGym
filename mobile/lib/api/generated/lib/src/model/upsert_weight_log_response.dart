//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/metrics.dart';
import 'package:viegym_api/src/model/weight_log_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_weight_log_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertWeightLogResponse {
  /// Returns a new [UpsertWeightLogResponse] instance.
  UpsertWeightLogResponse({
    this.weightLog,

    this.metricsUpdated,

    this.metrics,

    this.nutritionTargetChanged,
  });

  @JsonKey(name: r'weightLog', required: false, includeIfNull: false)
  final WeightLogDto? weightLog;

  @JsonKey(name: r'metricsUpdated', required: false, includeIfNull: false)
  final bool? metricsUpdated;

  @JsonKey(name: r'metrics', required: false, includeIfNull: false)
  final Metrics? metrics;

  @JsonKey(
    name: r'nutritionTargetChanged',
    required: false,
    includeIfNull: false,
  )
  final bool? nutritionTargetChanged;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertWeightLogResponse &&
          other.weightLog == weightLog &&
          other.metricsUpdated == metricsUpdated &&
          other.metrics == metrics &&
          other.nutritionTargetChanged == nutritionTargetChanged;

  @override
  int get hashCode =>
      weightLog.hashCode +
      metricsUpdated.hashCode +
      metrics.hashCode +
      nutritionTargetChanged.hashCode;

  factory UpsertWeightLogResponse.fromJson(Map<String, dynamic> json) =>
      _$UpsertWeightLogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertWeightLogResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
