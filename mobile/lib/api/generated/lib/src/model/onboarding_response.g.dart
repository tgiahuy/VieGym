// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OnboardingResponseCWProxy {
  OnboardingResponse healthProfileCompleted(bool? healthProfileCompleted);

  OnboardingResponse equipmentCompleted(bool? equipmentCompleted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingResponse call({
    bool? healthProfileCompleted,
    bool? equipmentCompleted,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOnboardingResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOnboardingResponse.copyWith.fieldName(...)`
class _$OnboardingResponseCWProxyImpl implements _$OnboardingResponseCWProxy {
  const _$OnboardingResponseCWProxyImpl(this._value);

  final OnboardingResponse _value;

  @override
  OnboardingResponse healthProfileCompleted(bool? healthProfileCompleted) =>
      this(healthProfileCompleted: healthProfileCompleted);

  @override
  OnboardingResponse equipmentCompleted(bool? equipmentCompleted) =>
      this(equipmentCompleted: equipmentCompleted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OnboardingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OnboardingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OnboardingResponse call({
    Object? healthProfileCompleted = const $CopyWithPlaceholder(),
    Object? equipmentCompleted = const $CopyWithPlaceholder(),
  }) {
    return OnboardingResponse(
      healthProfileCompleted:
          healthProfileCompleted == const $CopyWithPlaceholder()
          ? _value.healthProfileCompleted
          // ignore: cast_nullable_to_non_nullable
          : healthProfileCompleted as bool?,
      equipmentCompleted: equipmentCompleted == const $CopyWithPlaceholder()
          ? _value.equipmentCompleted
          // ignore: cast_nullable_to_non_nullable
          : equipmentCompleted as bool?,
    );
  }
}

extension $OnboardingResponseCopyWith on OnboardingResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOnboardingResponse.copyWith(...)` or like so:`instanceOfOnboardingResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OnboardingResponseCWProxy get copyWith =>
      _$OnboardingResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingResponse _$OnboardingResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OnboardingResponse', json, ($checkedConvert) {
      final val = OnboardingResponse(
        healthProfileCompleted: $checkedConvert(
          'healthProfileCompleted',
          (v) => v as bool?,
        ),
        equipmentCompleted: $checkedConvert(
          'equipmentCompleted',
          (v) => v as bool?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$OnboardingResponseToJson(OnboardingResponse instance) =>
    <String, dynamic>{
      'healthProfileCompleted': ?instance.healthProfileCompleted,
      'equipmentCompleted': ?instance.equipmentCompleted,
    };
