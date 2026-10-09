//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/nutrition.dart';
import 'package:viegym_api/src/model/meal_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Meal {
  /// Returns a new [Meal] instance.
  Meal({
    this.id,

    this.mealType,

    this.name,

    this.sortOrder,

    this.subtotal,

    this.entries,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'mealType', required: false, includeIfNull: false)
  final String? mealType;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'subtotal', required: false, includeIfNull: false)
  final Nutrition? subtotal;

  @JsonKey(name: r'entries', required: false, includeIfNull: false)
  final List<MealEntry>? entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          other.id == id &&
          other.mealType == mealType &&
          other.name == name &&
          other.sortOrder == sortOrder &&
          other.subtotal == subtotal &&
          other.entries == entries;

  @override
  int get hashCode =>
      id.hashCode +
      mealType.hashCode +
      name.hashCode +
      sortOrder.hashCode +
      subtotal.hashCode +
      entries.hashCode;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
