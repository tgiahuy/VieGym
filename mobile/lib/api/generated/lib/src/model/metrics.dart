//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Metrics {
  /// Returns a new [Metrics] instance.
  Metrics({this.bmi, this.bmrKcal, this.tdeeKcal});

  @JsonKey(name: r'bmi', required: false, includeIfNull: false)
  final num? bmi;

  @JsonKey(name: r'bmrKcal', required: false, includeIfNull: false)
  final num? bmrKcal;

  @JsonKey(name: r'tdeeKcal', required: false, includeIfNull: false)
  final num? tdeeKcal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Metrics &&
          other.bmi == bmi &&
          other.bmrKcal == bmrKcal &&
          other.tdeeKcal == tdeeKcal;

  @override
  int get hashCode => bmi.hashCode + bmrKcal.hashCode + tdeeKcal.hashCode;

  factory Metrics.fromJson(Map<String, dynamic> json) =>
      _$MetricsFromJson(json);

  Map<String, dynamic> toJson() => _$MetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
