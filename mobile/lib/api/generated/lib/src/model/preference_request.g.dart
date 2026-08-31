// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferenceRequestCWProxy {
  PreferenceRequest dislikedFoods(List<String>? dislikedFoods);

  PreferenceRequest allergies(List<String>? allergies);

  PreferenceRequest dietaryConstraints(List<String>? dietaryConstraints);

  PreferenceRequest mealPreferences(Map<String, Object>? mealPreferences);

  PreferenceRequest trainingPreferences(
    Map<String, Object>? trainingPreferences,
  );

  PreferenceRequest preferredTrainingTime(String? preferredTrainingTime);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceRequest call({
    List<String>? dislikedFoods,
    List<String>? allergies,
    List<String>? dietaryConstraints,
    Map<String, Object>? mealPreferences,
    Map<String, Object>? trainingPreferences,
    String? preferredTrainingTime,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferenceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferenceRequest.copyWith.fieldName(...)`
class _$PreferenceRequestCWProxyImpl implements _$PreferenceRequestCWProxy {
  const _$PreferenceRequestCWProxyImpl(this._value);

  final PreferenceRequest _value;

  @override
  PreferenceRequest dislikedFoods(List<String>? dislikedFoods) =>
      this(dislikedFoods: dislikedFoods);

  @override
  PreferenceRequest allergies(List<String>? allergies) =>
      this(allergies: allergies);

  @override
  PreferenceRequest dietaryConstraints(List<String>? dietaryConstraints) =>
      this(dietaryConstraints: dietaryConstraints);

  @override
  PreferenceRequest mealPreferences(Map<String, Object>? mealPreferences) =>
      this(mealPreferences: mealPreferences);

  @override
  PreferenceRequest trainingPreferences(
    Map<String, Object>? trainingPreferences,
  ) => this(trainingPreferences: trainingPreferences);

  @override
  PreferenceRequest preferredTrainingTime(String? preferredTrainingTime) =>
      this(preferredTrainingTime: preferredTrainingTime);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceRequest call({
    Object? dislikedFoods = const $CopyWithPlaceholder(),
    Object? allergies = const $CopyWithPlaceholder(),
    Object? dietaryConstraints = const $CopyWithPlaceholder(),
    Object? mealPreferences = const $CopyWithPlaceholder(),
    Object? trainingPreferences = const $CopyWithPlaceholder(),
    Object? preferredTrainingTime = const $CopyWithPlaceholder(),
  }) {
    return PreferenceRequest(
      dislikedFoods: dislikedFoods == const $CopyWithPlaceholder()
          ? _value.dislikedFoods
          // ignore: cast_nullable_to_non_nullable
          : dislikedFoods as List<String>?,
      allergies: allergies == const $CopyWithPlaceholder()
          ? _value.allergies
          // ignore: cast_nullable_to_non_nullable
          : allergies as List<String>?,
      dietaryConstraints: dietaryConstraints == const $CopyWithPlaceholder()
          ? _value.dietaryConstraints
          // ignore: cast_nullable_to_non_nullable
          : dietaryConstraints as List<String>?,
      mealPreferences: mealPreferences == const $CopyWithPlaceholder()
          ? _value.mealPreferences
          // ignore: cast_nullable_to_non_nullable
          : mealPreferences as Map<String, Object>?,
      trainingPreferences: trainingPreferences == const $CopyWithPlaceholder()
          ? _value.trainingPreferences
          // ignore: cast_nullable_to_non_nullable
          : trainingPreferences as Map<String, Object>?,
      preferredTrainingTime:
          preferredTrainingTime == const $CopyWithPlaceholder()
          ? _value.preferredTrainingTime
          // ignore: cast_nullable_to_non_nullable
          : preferredTrainingTime as String?,
    );
  }
}

extension $PreferenceRequestCopyWith on PreferenceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPreferenceRequest.copyWith(...)` or like so:`instanceOfPreferenceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferenceRequestCWProxy get copyWith =>
      _$PreferenceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferenceRequest _$PreferenceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PreferenceRequest', json, ($checkedConvert) {
  final val = PreferenceRequest(
    dislikedFoods: $checkedConvert(
      'dislikedFoods',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    allergies: $checkedConvert(
      'allergies',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    dietaryConstraints: $checkedConvert(
      'dietaryConstraints',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    mealPreferences: $checkedConvert(
      'mealPreferences',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    trainingPreferences: $checkedConvert(
      'trainingPreferences',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    preferredTrainingTime: $checkedConvert(
      'preferredTrainingTime',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$PreferenceRequestToJson(PreferenceRequest instance) =>
    <String, dynamic>{
      'dislikedFoods': ?instance.dislikedFoods,
      'allergies': ?instance.allergies,
      'dietaryConstraints': ?instance.dietaryConstraints,
      'mealPreferences': ?instance.mealPreferences,
      'trainingPreferences': ?instance.trainingPreferences,
      'preferredTrainingTime': ?instance.preferredTrainingTime,
    };
