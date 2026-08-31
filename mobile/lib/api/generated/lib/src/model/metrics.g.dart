// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MetricsCWProxy {
  Metrics bmi(num? bmi);

  Metrics bmrKcal(num? bmrKcal);

  Metrics tdeeKcal(num? tdeeKcal);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Metrics(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Metrics(...).copyWith(id: 12, name: "My name")
  /// ````
  Metrics call({num? bmi, num? bmrKcal, num? tdeeKcal});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMetrics.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMetrics.copyWith.fieldName(...)`
class _$MetricsCWProxyImpl implements _$MetricsCWProxy {
  const _$MetricsCWProxyImpl(this._value);

  final Metrics _value;

  @override
  Metrics bmi(num? bmi) => this(bmi: bmi);

  @override
  Metrics bmrKcal(num? bmrKcal) => this(bmrKcal: bmrKcal);

  @override
  Metrics tdeeKcal(num? tdeeKcal) => this(tdeeKcal: tdeeKcal);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Metrics(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Metrics(...).copyWith(id: 12, name: "My name")
  /// ````
  Metrics call({
    Object? bmi = const $CopyWithPlaceholder(),
    Object? bmrKcal = const $CopyWithPlaceholder(),
    Object? tdeeKcal = const $CopyWithPlaceholder(),
  }) {
    return Metrics(
      bmi: bmi == const $CopyWithPlaceholder()
          ? _value.bmi
          // ignore: cast_nullable_to_non_nullable
          : bmi as num?,
      bmrKcal: bmrKcal == const $CopyWithPlaceholder()
          ? _value.bmrKcal
          // ignore: cast_nullable_to_non_nullable
          : bmrKcal as num?,
      tdeeKcal: tdeeKcal == const $CopyWithPlaceholder()
          ? _value.tdeeKcal
          // ignore: cast_nullable_to_non_nullable
          : tdeeKcal as num?,
    );
  }
}

extension $MetricsCopyWith on Metrics {
  /// Returns a callable class that can be used as follows: `instanceOfMetrics.copyWith(...)` or like so:`instanceOfMetrics.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MetricsCWProxy get copyWith => _$MetricsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metrics _$MetricsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Metrics', json, ($checkedConvert) {
      final val = Metrics(
        bmi: $checkedConvert('bmi', (v) => v as num?),
        bmrKcal: $checkedConvert('bmrKcal', (v) => v as num?),
        tdeeKcal: $checkedConvert('tdeeKcal', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$MetricsToJson(Metrics instance) => <String, dynamic>{
  'bmi': ?instance.bmi,
  'bmrKcal': ?instance.bmrKcal,
  'tdeeKcal': ?instance.tdeeKcal,
};
