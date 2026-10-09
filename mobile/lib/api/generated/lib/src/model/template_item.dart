//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TemplateItem {
  /// Returns a new [TemplateItem] instance.
  TemplateItem({
    this.id,

    this.foodId,

    this.foodName,

    this.mealType,

    this.sortOrder,

    this.servingMultiplier,

    this.servingAmount,

    this.servingUnit,

    this.available,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'foodId', required: false, includeIfNull: false)
  final int? foodId;

  @JsonKey(name: r'foodName', required: false, includeIfNull: false)
  final String? foodName;

  @JsonKey(name: r'mealType', required: false, includeIfNull: false)
  final String? mealType;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'servingMultiplier', required: false, includeIfNull: false)
  final num? servingMultiplier;

  @JsonKey(name: r'servingAmount', required: false, includeIfNull: false)
  final num? servingAmount;

  @JsonKey(name: r'servingUnit', required: false, includeIfNull: false)
  final String? servingUnit;

  @JsonKey(name: r'available', required: false, includeIfNull: false)
  final bool? available;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateItem &&
          other.id == id &&
          other.foodId == foodId &&
          other.foodName == foodName &&
          other.mealType == mealType &&
          other.sortOrder == sortOrder &&
          other.servingMultiplier == servingMultiplier &&
          other.servingAmount == servingAmount &&
          other.servingUnit == servingUnit &&
          other.available == available;

  @override
  int get hashCode =>
      id.hashCode +
      foodId.hashCode +
      foodName.hashCode +
      mealType.hashCode +
      sortOrder.hashCode +
      servingMultiplier.hashCode +
      servingAmount.hashCode +
      servingUnit.hashCode +
      available.hashCode;

  factory TemplateItem.fromJson(Map<String, dynamic> json) =>
      _$TemplateItemFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
