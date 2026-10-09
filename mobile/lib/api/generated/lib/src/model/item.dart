//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Item {
  /// Returns a new [Item] instance.
  Item({
    this.foodId,

    required this.mealType,

    this.sortOrder,

    this.servingMultiplier,
  });

  @JsonKey(name: r'foodId', required: false, includeIfNull: false)
  final int? foodId;

  @JsonKey(name: r'mealType', required: true, includeIfNull: false)
  final String mealType;

  @JsonKey(name: r'sortOrder', required: false, includeIfNull: false)
  final int? sortOrder;

  @JsonKey(name: r'servingMultiplier', required: false, includeIfNull: false)
  final num? servingMultiplier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          other.foodId == foodId &&
          other.mealType == mealType &&
          other.sortOrder == sortOrder &&
          other.servingMultiplier == servingMultiplier;

  @override
  int get hashCode =>
      foodId.hashCode +
      mealType.hashCode +
      sortOrder.hashCode +
      servingMultiplier.hashCode;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
