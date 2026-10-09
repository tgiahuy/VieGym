// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_trend_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightTrendResponseCWProxy {
  WeightTrendResponse days(int? days);

  WeightTrendResponse from(DateTime? from);

  WeightTrendResponse to(DateTime? to);

  WeightTrendResponse startWeightKg(num? startWeightKg);

  WeightTrendResponse currentWeightKg(num? currentWeightKg);

  WeightTrendResponse changeKg(num? changeKg);

  WeightTrendResponse direction(WeightTrendResponseDirectionEnum? direction);

  WeightTrendResponse sufficientData(bool? sufficientData);

  WeightTrendResponse points(List<WeightTrendPoint>? points);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightTrendResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightTrendResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightTrendResponse call({
    int? days,
    DateTime? from,
    DateTime? to,
    num? startWeightKg,
    num? currentWeightKg,
    num? changeKg,
    WeightTrendResponseDirectionEnum? direction,
    bool? sufficientData,
    List<WeightTrendPoint>? points,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightTrendResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightTrendResponse.copyWith.fieldName(...)`
class _$WeightTrendResponseCWProxyImpl implements _$WeightTrendResponseCWProxy {
  const _$WeightTrendResponseCWProxyImpl(this._value);

  final WeightTrendResponse _value;

  @override
  WeightTrendResponse days(int? days) => this(days: days);

  @override
  WeightTrendResponse from(DateTime? from) => this(from: from);

  @override
  WeightTrendResponse to(DateTime? to) => this(to: to);

  @override
  WeightTrendResponse startWeightKg(num? startWeightKg) =>
      this(startWeightKg: startWeightKg);

  @override
  WeightTrendResponse currentWeightKg(num? currentWeightKg) =>
      this(currentWeightKg: currentWeightKg);

  @override
  WeightTrendResponse changeKg(num? changeKg) => this(changeKg: changeKg);

  @override
  WeightTrendResponse direction(WeightTrendResponseDirectionEnum? direction) =>
      this(direction: direction);

  @override
  WeightTrendResponse sufficientData(bool? sufficientData) =>
      this(sufficientData: sufficientData);

  @override
  WeightTrendResponse points(List<WeightTrendPoint>? points) =>
      this(points: points);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightTrendResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightTrendResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightTrendResponse call({
    Object? days = const $CopyWithPlaceholder(),
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
    Object? startWeightKg = const $CopyWithPlaceholder(),
    Object? currentWeightKg = const $CopyWithPlaceholder(),
    Object? changeKg = const $CopyWithPlaceholder(),
    Object? direction = const $CopyWithPlaceholder(),
    Object? sufficientData = const $CopyWithPlaceholder(),
    Object? points = const $CopyWithPlaceholder(),
  }) {
    return WeightTrendResponse(
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int?,
      from: from == const $CopyWithPlaceholder()
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as DateTime?,
      to: to == const $CopyWithPlaceholder()
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as DateTime?,
      startWeightKg: startWeightKg == const $CopyWithPlaceholder()
          ? _value.startWeightKg
          // ignore: cast_nullable_to_non_nullable
          : startWeightKg as num?,
      currentWeightKg: currentWeightKg == const $CopyWithPlaceholder()
          ? _value.currentWeightKg
          // ignore: cast_nullable_to_non_nullable
          : currentWeightKg as num?,
      changeKg: changeKg == const $CopyWithPlaceholder()
          ? _value.changeKg
          // ignore: cast_nullable_to_non_nullable
          : changeKg as num?,
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as WeightTrendResponseDirectionEnum?,
      sufficientData: sufficientData == const $CopyWithPlaceholder()
          ? _value.sufficientData
          // ignore: cast_nullable_to_non_nullable
          : sufficientData as bool?,
      points: points == const $CopyWithPlaceholder()
          ? _value.points
          // ignore: cast_nullable_to_non_nullable
          : points as List<WeightTrendPoint>?,
    );
  }
}

extension $WeightTrendResponseCopyWith on WeightTrendResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWeightTrendResponse.copyWith(...)` or like so:`instanceOfWeightTrendResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightTrendResponseCWProxy get copyWith =>
      _$WeightTrendResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightTrendResponse _$WeightTrendResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightTrendResponse', json, ($checkedConvert) {
      final val = WeightTrendResponse(
        days: $checkedConvert('days', (v) => (v as num?)?.toInt()),
        from: $checkedConvert(
          'from',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        to: $checkedConvert(
          'to',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        startWeightKg: $checkedConvert('startWeightKg', (v) => v as num?),
        currentWeightKg: $checkedConvert('currentWeightKg', (v) => v as num?),
        changeKg: $checkedConvert('changeKg', (v) => v as num?),
        direction: $checkedConvert(
          'direction',
          (v) =>
              $enumDecodeNullable(_$WeightTrendResponseDirectionEnumEnumMap, v),
        ),
        sufficientData: $checkedConvert('sufficientData', (v) => v as bool?),
        points: $checkedConvert(
          'points',
          (v) => (v as List<dynamic>?)
              ?.map((e) => WeightTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeightTrendResponseToJson(
  WeightTrendResponse instance,
) => <String, dynamic>{
  'days': ?instance.days,
  'from': ?instance.from?.toIso8601String(),
  'to': ?instance.to?.toIso8601String(),
  'startWeightKg': ?instance.startWeightKg,
  'currentWeightKg': ?instance.currentWeightKg,
  'changeKg': ?instance.changeKg,
  'direction': ?_$WeightTrendResponseDirectionEnumEnumMap[instance.direction],
  'sufficientData': ?instance.sufficientData,
  'points': ?instance.points?.map((e) => e.toJson()).toList(),
};

const _$WeightTrendResponseDirectionEnumEnumMap = {
  WeightTrendResponseDirectionEnum.UP: 'UP',
  WeightTrendResponseDirectionEnum.DOWN: 'DOWN',
  WeightTrendResponseDirectionEnum.STABLE: 'STABLE',
};
