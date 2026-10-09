// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_section.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BodySectionCWProxy {
  BodySection currentWeightKg(num? currentWeightKg);

  BodySection bmi(num? bmi);

  BodySection trend(String? trend);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BodySection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BodySection(...).copyWith(id: 12, name: "My name")
  /// ````
  BodySection call({num? currentWeightKg, num? bmi, String? trend});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBodySection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBodySection.copyWith.fieldName(...)`
class _$BodySectionCWProxyImpl implements _$BodySectionCWProxy {
  const _$BodySectionCWProxyImpl(this._value);

  final BodySection _value;

  @override
  BodySection currentWeightKg(num? currentWeightKg) =>
      this(currentWeightKg: currentWeightKg);

  @override
  BodySection bmi(num? bmi) => this(bmi: bmi);

  @override
  BodySection trend(String? trend) => this(trend: trend);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BodySection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BodySection(...).copyWith(id: 12, name: "My name")
  /// ````
  BodySection call({
    Object? currentWeightKg = const $CopyWithPlaceholder(),
    Object? bmi = const $CopyWithPlaceholder(),
    Object? trend = const $CopyWithPlaceholder(),
  }) {
    return BodySection(
      currentWeightKg: currentWeightKg == const $CopyWithPlaceholder()
          ? _value.currentWeightKg
          // ignore: cast_nullable_to_non_nullable
          : currentWeightKg as num?,
      bmi: bmi == const $CopyWithPlaceholder()
          ? _value.bmi
          // ignore: cast_nullable_to_non_nullable
          : bmi as num?,
      trend: trend == const $CopyWithPlaceholder()
          ? _value.trend
          // ignore: cast_nullable_to_non_nullable
          : trend as String?,
    );
  }
}

extension $BodySectionCopyWith on BodySection {
  /// Returns a callable class that can be used as follows: `instanceOfBodySection.copyWith(...)` or like so:`instanceOfBodySection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BodySectionCWProxy get copyWith => _$BodySectionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodySection _$BodySectionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BodySection', json, ($checkedConvert) {
      final val = BodySection(
        currentWeightKg: $checkedConvert('currentWeightKg', (v) => v as num?),
        bmi: $checkedConvert('bmi', (v) => v as num?),
        trend: $checkedConvert('trend', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$BodySectionToJson(BodySection instance) =>
    <String, dynamic>{
      'currentWeightKg': ?instance.currentWeightKg,
      'bmi': ?instance.bmi,
      'trend': ?instance.trend,
    };
