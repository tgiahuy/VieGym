// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthProfileResponseCWProxy {
  HealthProfileResponse profile(Profile? profile);

  HealthProfileResponse calculationStatus(String? calculationStatus);

  HealthProfileResponse metrics(Metrics? metrics);

  HealthProfileResponse nutritionTarget(NutritionTarget? nutritionTarget);

  HealthProfileResponse incompleteReason(
    HealthProfileResponseIncompleteReasonEnum? incompleteReason,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthProfileResponse call({
    Profile? profile,
    String? calculationStatus,
    Metrics? metrics,
    NutritionTarget? nutritionTarget,
    HealthProfileResponseIncompleteReasonEnum? incompleteReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthProfileResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthProfileResponse.copyWith.fieldName(...)`
class _$HealthProfileResponseCWProxyImpl
    implements _$HealthProfileResponseCWProxy {
  const _$HealthProfileResponseCWProxyImpl(this._value);

  final HealthProfileResponse _value;

  @override
  HealthProfileResponse profile(Profile? profile) => this(profile: profile);

  @override
  HealthProfileResponse calculationStatus(String? calculationStatus) =>
      this(calculationStatus: calculationStatus);

  @override
  HealthProfileResponse metrics(Metrics? metrics) => this(metrics: metrics);

  @override
  HealthProfileResponse nutritionTarget(NutritionTarget? nutritionTarget) =>
      this(nutritionTarget: nutritionTarget);

  @override
  HealthProfileResponse incompleteReason(
    HealthProfileResponseIncompleteReasonEnum? incompleteReason,
  ) => this(incompleteReason: incompleteReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthProfileResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthProfileResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthProfileResponse call({
    Object? profile = const $CopyWithPlaceholder(),
    Object? calculationStatus = const $CopyWithPlaceholder(),
    Object? metrics = const $CopyWithPlaceholder(),
    Object? nutritionTarget = const $CopyWithPlaceholder(),
    Object? incompleteReason = const $CopyWithPlaceholder(),
  }) {
    return HealthProfileResponse(
      profile: profile == const $CopyWithPlaceholder()
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as Profile?,
      calculationStatus: calculationStatus == const $CopyWithPlaceholder()
          ? _value.calculationStatus
          // ignore: cast_nullable_to_non_nullable
          : calculationStatus as String?,
      metrics: metrics == const $CopyWithPlaceholder()
          ? _value.metrics
          // ignore: cast_nullable_to_non_nullable
          : metrics as Metrics?,
      nutritionTarget: nutritionTarget == const $CopyWithPlaceholder()
          ? _value.nutritionTarget
          // ignore: cast_nullable_to_non_nullable
          : nutritionTarget as NutritionTarget?,
      incompleteReason: incompleteReason == const $CopyWithPlaceholder()
          ? _value.incompleteReason
          // ignore: cast_nullable_to_non_nullable
          : incompleteReason as HealthProfileResponseIncompleteReasonEnum?,
    );
  }
}

extension $HealthProfileResponseCopyWith on HealthProfileResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHealthProfileResponse.copyWith(...)` or like so:`instanceOfHealthProfileResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthProfileResponseCWProxy get copyWith =>
      _$HealthProfileResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthProfileResponse _$HealthProfileResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HealthProfileResponse', json, ($checkedConvert) {
  final val = HealthProfileResponse(
    profile: $checkedConvert(
      'profile',
      (v) => v == null ? null : Profile.fromJson(v as Map<String, dynamic>),
    ),
    calculationStatus: $checkedConvert(
      'calculationStatus',
      (v) => v as String?,
    ),
    metrics: $checkedConvert(
      'metrics',
      (v) => v == null ? null : Metrics.fromJson(v as Map<String, dynamic>),
    ),
    nutritionTarget: $checkedConvert(
      'nutritionTarget',
      (v) => v == null
          ? null
          : NutritionTarget.fromJson(v as Map<String, dynamic>),
    ),
    incompleteReason: $checkedConvert(
      'incompleteReason',
      (v) => $enumDecodeNullable(
        _$HealthProfileResponseIncompleteReasonEnumEnumMap,
        v,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$HealthProfileResponseToJson(
  HealthProfileResponse instance,
) => <String, dynamic>{
  'profile': ?instance.profile?.toJson(),
  'calculationStatus': ?instance.calculationStatus,
  'metrics': ?instance.metrics?.toJson(),
  'nutritionTarget': ?instance.nutritionTarget?.toJson(),
  'incompleteReason':
      ?_$HealthProfileResponseIncompleteReasonEnumEnumMap[instance
          .incompleteReason],
};

const _$HealthProfileResponseIncompleteReasonEnumEnumMap = {
  HealthProfileResponseIncompleteReasonEnum.CALCULATION_SEX_REQUIRED:
      'CALCULATION_SEX_REQUIRED',
  HealthProfileResponseIncompleteReasonEnum.UNSUPPORTED_AGE: 'UNSUPPORTED_AGE',
  HealthProfileResponseIncompleteReasonEnum.CALORIES_BELOW_SAFETY_THRESHOLD:
      'CALORIES_BELOW_SAFETY_THRESHOLD',
  HealthProfileResponseIncompleteReasonEnum.INVALID_MACRO_RESULT:
      'INVALID_MACRO_RESULT',
};
