//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/nutrition.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealEntry {
  /// Returns a new [MealEntry] instance.
  MealEntry({
    this.id,

    this.foodId,

    this.foodName,

    this.mealType,

    this.mealSortOrder,

    this.servingMultiplier,

    this.inputAmount,

    this.inputUnit,

    this.servingAmount,

    this.servingUnit,

    this.nutrition,

    this.estimated,

    this.note,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'foodId', required: false, includeIfNull: false)
  final int? foodId;

  @JsonKey(name: r'foodName', required: false, includeIfNull: false)
  final String? foodName;

  @JsonKey(name: r'mealType', required: false, includeIfNull: false)
  final String? mealType;

  @JsonKey(name: r'mealSortOrder', required: false, includeIfNull: false)
  final int? mealSortOrder;

  @JsonKey(name: r'servingMultiplier', required: false, includeIfNull: false)
  final num? servingMultiplier;

  @JsonKey(name: r'inputAmount', required: false, includeIfNull: false)
  final num? inputAmount;

  @JsonKey(name: r'inputUnit', required: false, includeIfNull: false)
  final String? inputUnit;

  @JsonKey(name: r'servingAmount', required: false, includeIfNull: false)
  final num? servingAmount;

  @JsonKey(name: r'servingUnit', required: false, includeIfNull: false)
  final String? servingUnit;

  @JsonKey(name: r'nutrition', required: false, includeIfNull: false)
  final Nutrition? nutrition;

  @JsonKey(name: r'estimated', required: false, includeIfNull: false)
  final bool? estimated;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntry &&
          other.id == id &&
          other.foodId == foodId &&
          other.foodName == foodName &&
          other.mealType == mealType &&
          other.mealSortOrder == mealSortOrder &&
          other.servingMultiplier == servingMultiplier &&
          other.inputAmount == inputAmount &&
          other.inputUnit == inputUnit &&
          other.servingAmount == servingAmount &&
          other.servingUnit == servingUnit &&
          other.nutrition == nutrition &&
          other.estimated == estimated &&
          other.note == note;

  @override
  int get hashCode =>
      id.hashCode +
      foodId.hashCode +
      foodName.hashCode +
      mealType.hashCode +
      mealSortOrder.hashCode +
      servingMultiplier.hashCode +
      inputAmount.hashCode +
      inputUnit.hashCode +
      servingAmount.hashCode +
      servingUnit.hashCode +
      nutrition.hashCode +
      estimated.hashCode +
      note.hashCode;

  factory MealEntry.fromJson(Map<String, dynamic> json) =>
      _$MealEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MealEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
