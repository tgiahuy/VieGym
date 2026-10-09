// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_weight_log_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpsertWeightLogResponseCWProxy {
  UpsertWeightLogResponse weightLog(WeightLogDto? weightLog);

  UpsertWeightLogResponse metricsUpdated(bool? metricsUpdated);

  UpsertWeightLogResponse metrics(Metrics? metrics);

  UpsertWeightLogResponse nutritionTargetChanged(bool? nutritionTargetChanged);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertWeightLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertWeightLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertWeightLogResponse call({
    WeightLogDto? weightLog,
    bool? metricsUpdated,
    Metrics? metrics,
    bool? nutritionTargetChanged,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpsertWeightLogResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpsertWeightLogResponse.copyWith.fieldName(...)`
class _$UpsertWeightLogResponseCWProxyImpl
    implements _$UpsertWeightLogResponseCWProxy {
  const _$UpsertWeightLogResponseCWProxyImpl(this._value);

  final UpsertWeightLogResponse _value;

  @override
  UpsertWeightLogResponse weightLog(WeightLogDto? weightLog) =>
      this(weightLog: weightLog);

  @override
  UpsertWeightLogResponse metricsUpdated(bool? metricsUpdated) =>
      this(metricsUpdated: metricsUpdated);

  @override
  UpsertWeightLogResponse metrics(Metrics? metrics) => this(metrics: metrics);

  @override
  UpsertWeightLogResponse nutritionTargetChanged(
    bool? nutritionTargetChanged,
  ) => this(nutritionTargetChanged: nutritionTargetChanged);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertWeightLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertWeightLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertWeightLogResponse call({
    Object? weightLog = const $CopyWithPlaceholder(),
    Object? metricsUpdated = const $CopyWithPlaceholder(),
    Object? metrics = const $CopyWithPlaceholder(),
    Object? nutritionTargetChanged = const $CopyWithPlaceholder(),
  }) {
    return UpsertWeightLogResponse(
      weightLog: weightLog == const $CopyWithPlaceholder()
          ? _value.weightLog
          // ignore: cast_nullable_to_non_nullable
          : weightLog as WeightLogDto?,
      metricsUpdated: metricsUpdated == const $CopyWithPlaceholder()
          ? _value.metricsUpdated
          // ignore: cast_nullable_to_non_nullable
          : metricsUpdated as bool?,
      metrics: metrics == const $CopyWithPlaceholder()
          ? _value.metrics
          // ignore: cast_nullable_to_non_nullable
          : metrics as Metrics?,
      nutritionTargetChanged:
          nutritionTargetChanged == const $CopyWithPlaceholder()
          ? _value.nutritionTargetChanged
          // ignore: cast_nullable_to_non_nullable
          : nutritionTargetChanged as bool?,
    );
  }
}

extension $UpsertWeightLogResponseCopyWith on UpsertWeightLogResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUpsertWeightLogResponse.copyWith(...)` or like so:`instanceOfUpsertWeightLogResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpsertWeightLogResponseCWProxy get copyWith =>
      _$UpsertWeightLogResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpsertWeightLogResponse _$UpsertWeightLogResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpsertWeightLogResponse', json, ($checkedConvert) {
  final val = UpsertWeightLogResponse(
    weightLog: $checkedConvert(
      'weightLog',
      (v) =>
          v == null ? null : WeightLogDto.fromJson(v as Map<String, dynamic>),
    ),
    metricsUpdated: $checkedConvert('metricsUpdated', (v) => v as bool?),
    metrics: $checkedConvert(
      'metrics',
      (v) => v == null ? null : Metrics.fromJson(v as Map<String, dynamic>),
    ),
    nutritionTargetChanged: $checkedConvert(
      'nutritionTargetChanged',
      (v) => v as bool?,
    ),
  );
  return val;
});

Map<String, dynamic> _$UpsertWeightLogResponseToJson(
  UpsertWeightLogResponse instance,
) => <String, dynamic>{
  'weightLog': ?instance.weightLog?.toJson(),
  'metricsUpdated': ?instance.metricsUpdated,
  'metrics': ?instance.metrics?.toJson(),
  'nutritionTargetChanged': ?instance.nutritionTargetChanged,
};
