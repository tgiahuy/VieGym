//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/weight_trend_point.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_trend_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightTrendResponse {
  /// Returns a new [WeightTrendResponse] instance.
  WeightTrendResponse({
    this.days,

    this.from,

    this.to,

    this.startWeightKg,

    this.currentWeightKg,

    this.changeKg,

    this.direction,

    this.sufficientData,

    this.points,
  });

  @JsonKey(name: r'days', required: false, includeIfNull: false)
  final int? days;

  @JsonKey(name: r'from', required: false, includeIfNull: false)
  final DateTime? from;

  @JsonKey(name: r'to', required: false, includeIfNull: false)
  final DateTime? to;

  @JsonKey(name: r'startWeightKg', required: false, includeIfNull: false)
  final num? startWeightKg;

  @JsonKey(name: r'currentWeightKg', required: false, includeIfNull: false)
  final num? currentWeightKg;

  @JsonKey(name: r'changeKg', required: false, includeIfNull: false)
  final num? changeKg;

  @JsonKey(name: r'direction', required: false, includeIfNull: false)
  final WeightTrendResponseDirectionEnum? direction;

  @JsonKey(name: r'sufficientData', required: false, includeIfNull: false)
  final bool? sufficientData;

  @JsonKey(name: r'points', required: false, includeIfNull: false)
  final List<WeightTrendPoint>? points;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightTrendResponse &&
          other.days == days &&
          other.from == from &&
          other.to == to &&
          other.startWeightKg == startWeightKg &&
          other.currentWeightKg == currentWeightKg &&
          other.changeKg == changeKg &&
          other.direction == direction &&
          other.sufficientData == sufficientData &&
          other.points == points;

  @override
  int get hashCode =>
      days.hashCode +
      from.hashCode +
      to.hashCode +
      startWeightKg.hashCode +
      currentWeightKg.hashCode +
      changeKg.hashCode +
      direction.hashCode +
      sufficientData.hashCode +
      points.hashCode;

  factory WeightTrendResponse.fromJson(Map<String, dynamic> json) =>
      _$WeightTrendResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WeightTrendResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum WeightTrendResponseDirectionEnum {
  @JsonValue(r'UP')
  UP(r'UP'),
  @JsonValue(r'DOWN')
  DOWN(r'DOWN'),
  @JsonValue(r'STABLE')
  STABLE(r'STABLE');

  const WeightTrendResponseDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
