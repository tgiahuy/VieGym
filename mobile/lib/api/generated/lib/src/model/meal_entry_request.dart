//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_entry_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealEntryRequest {
  /// Returns a new [MealEntryRequest] instance.
  MealEntryRequest({
    required this.mealType,

    this.mealSortOrder,

    this.foodId,

    this.servingMultiplier,

    this.inputAmount,

    this.inputUnit,

    this.note,
  });

  @JsonKey(name: r'mealType', required: true, includeIfNull: false)
  final String mealType;

  @JsonKey(name: r'mealSortOrder', required: false, includeIfNull: false)
  final int? mealSortOrder;

  @JsonKey(name: r'foodId', required: false, includeIfNull: false)
  final int? foodId;

  // minimum: 0.001
  @JsonKey(name: r'servingMultiplier', required: false, includeIfNull: false)
  final num? servingMultiplier;

  // minimum: 0.01
  @JsonKey(name: r'inputAmount', required: false, includeIfNull: false)
  final num? inputAmount;

  @JsonKey(name: r'inputUnit', required: false, includeIfNull: false)
  final String? inputUnit;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntryRequest &&
          other.mealType == mealType &&
          other.mealSortOrder == mealSortOrder &&
          other.foodId == foodId &&
          other.servingMultiplier == servingMultiplier &&
          other.inputAmount == inputAmount &&
          other.inputUnit == inputUnit &&
          other.note == note;

  @override
  int get hashCode =>
      mealType.hashCode +
      mealSortOrder.hashCode +
      foodId.hashCode +
      servingMultiplier.hashCode +
      inputAmount.hashCode +
      inputUnit.hashCode +
      note.hashCode;

  factory MealEntryRequest.fromJson(Map<String, dynamic> json) =>
      _$MealEntryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MealEntryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
