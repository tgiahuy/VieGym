//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'body_section.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BodySection {
  /// Returns a new [BodySection] instance.
  BodySection({this.currentWeightKg, this.bmi, this.trend});

  @JsonKey(name: r'currentWeightKg', required: false, includeIfNull: false)
  final num? currentWeightKg;

  @JsonKey(name: r'bmi', required: false, includeIfNull: false)
  final num? bmi;

  @JsonKey(name: r'trend', required: false, includeIfNull: false)
  final String? trend;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodySection &&
          other.currentWeightKg == currentWeightKg &&
          other.bmi == bmi &&
          other.trend == trend;

  @override
  int get hashCode => currentWeightKg.hashCode + bmi.hashCode + trend.hashCode;

  factory BodySection.fromJson(Map<String, dynamic> json) =>
      _$BodySectionFromJson(json);

  Map<String, dynamic> toJson() => _$BodySectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
