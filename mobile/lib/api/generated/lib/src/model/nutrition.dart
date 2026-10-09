//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nutrition.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Nutrition {
  /// Returns a new [Nutrition] instance.
  Nutrition({this.caloriesKcal, this.proteinG, this.carbsG, this.fatG});

  @JsonKey(name: r'caloriesKcal', required: false, includeIfNull: false)
  final num? caloriesKcal;

  @JsonKey(name: r'proteinG', required: false, includeIfNull: false)
  final num? proteinG;

  @JsonKey(name: r'carbsG', required: false, includeIfNull: false)
  final num? carbsG;

  @JsonKey(name: r'fatG', required: false, includeIfNull: false)
  final num? fatG;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Nutrition &&
          other.caloriesKcal == caloriesKcal &&
          other.proteinG == proteinG &&
          other.carbsG == carbsG &&
          other.fatG == fatG;

  @override
  int get hashCode =>
      caloriesKcal.hashCode +
      proteinG.hashCode +
      carbsG.hashCode +
      fatG.hashCode;

  factory Nutrition.fromJson(Map<String, dynamic> json) =>
      _$NutritionFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
