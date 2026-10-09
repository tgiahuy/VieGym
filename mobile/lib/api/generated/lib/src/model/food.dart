//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/nutrition.dart';
import 'package:viegym_api/src/model/serving.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'food.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Food {
  /// Returns a new [Food] instance.
  Food({
    this.id,

    this.name,

    this.slug,

    this.category,

    this.serving,

    this.nutritionPerServing,

    this.dataSource,

    this.sourceNote,

    this.estimated,

    this.selectable,

    this.media,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'slug', required: false, includeIfNull: false)
  final String? slug;

  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final String? category;

  @JsonKey(name: r'serving', required: false, includeIfNull: false)
  final Serving? serving;

  @JsonKey(name: r'nutritionPerServing', required: false, includeIfNull: false)
  final Nutrition? nutritionPerServing;

  @JsonKey(name: r'dataSource', required: false, includeIfNull: false)
  final String? dataSource;

  @JsonKey(name: r'sourceNote', required: false, includeIfNull: false)
  final String? sourceNote;

  @JsonKey(name: r'estimated', required: false, includeIfNull: false)
  final bool? estimated;

  @JsonKey(name: r'selectable', required: false, includeIfNull: false)
  final bool? selectable;

  @JsonKey(name: r'media', required: false, includeIfNull: false)
  final List<Object>? media;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food &&
          other.id == id &&
          other.name == name &&
          other.slug == slug &&
          other.category == category &&
          other.serving == serving &&
          other.nutritionPerServing == nutritionPerServing &&
          other.dataSource == dataSource &&
          other.sourceNote == sourceNote &&
          other.estimated == estimated &&
          other.selectable == selectable &&
          other.media == media;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      slug.hashCode +
      category.hashCode +
      serving.hashCode +
      nutritionPerServing.hashCode +
      dataSource.hashCode +
      sourceNote.hashCode +
      estimated.hashCode +
      selectable.hashCode +
      media.hashCode;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);

  Map<String, dynamic> toJson() => _$FoodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
