//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_trend_point.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightTrendPoint {
  /// Returns a new [WeightTrendPoint] instance.
  WeightTrendPoint({this.date, this.weightKg});

  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final DateTime? date;

  @JsonKey(name: r'weightKg', required: false, includeIfNull: false)
  final num? weightKg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightTrendPoint &&
          other.date == date &&
          other.weightKg == weightKg;

  @override
  int get hashCode => date.hashCode + weightKg.hashCode;

  factory WeightTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$WeightTrendPointFromJson(json);

  Map<String, dynamic> toJson() => _$WeightTrendPointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
