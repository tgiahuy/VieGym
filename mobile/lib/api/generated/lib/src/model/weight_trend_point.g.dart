// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_trend_point.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightTrendPointCWProxy {
  WeightTrendPoint date(DateTime? date);

  WeightTrendPoint weightKg(num? weightKg);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightTrendPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightTrendPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightTrendPoint call({DateTime? date, num? weightKg});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightTrendPoint.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightTrendPoint.copyWith.fieldName(...)`
class _$WeightTrendPointCWProxyImpl implements _$WeightTrendPointCWProxy {
  const _$WeightTrendPointCWProxyImpl(this._value);

  final WeightTrendPoint _value;

  @override
  WeightTrendPoint date(DateTime? date) => this(date: date);

  @override
  WeightTrendPoint weightKg(num? weightKg) => this(weightKg: weightKg);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightTrendPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightTrendPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightTrendPoint call({
    Object? date = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
  }) {
    return WeightTrendPoint(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime?,
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as num?,
    );
  }
}

extension $WeightTrendPointCopyWith on WeightTrendPoint {
  /// Returns a callable class that can be used as follows: `instanceOfWeightTrendPoint.copyWith(...)` or like so:`instanceOfWeightTrendPoint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightTrendPointCWProxy get copyWith => _$WeightTrendPointCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightTrendPoint _$WeightTrendPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightTrendPoint', json, ($checkedConvert) {
      final val = WeightTrendPoint(
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        weightKg: $checkedConvert('weightKg', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$WeightTrendPointToJson(WeightTrendPoint instance) =>
    <String, dynamic>{
      'date': ?instance.date?.toIso8601String(),
      'weightKg': ?instance.weightKg,
    };
