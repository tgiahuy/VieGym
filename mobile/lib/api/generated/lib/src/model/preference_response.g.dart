// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferenceResponseCWProxy {
  PreferenceResponse dislikedFoods(List<String>? dislikedFoods);

  PreferenceResponse allergies(List<String>? allergies);

  PreferenceResponse dietaryConstraints(List<String>? dietaryConstraints);

  PreferenceResponse mealPreferences(Map<String, Object>? mealPreferences);

  PreferenceResponse trainingPreferences(
    Map<String, Object>? trainingPreferences,
  );

  PreferenceResponse preferredTrainingTime(String? preferredTrainingTime);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceResponse call({
    List<String>? dislikedFoods,
    List<String>? allergies,
    List<String>? dietaryConstraints,
    Map<String, Object>? mealPreferences,
    Map<String, Object>? trainingPreferences,
    String? preferredTrainingTime,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferenceResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferenceResponse.copyWith.fieldName(...)`
class _$PreferenceResponseCWProxyImpl implements _$PreferenceResponseCWProxy {
  const _$PreferenceResponseCWProxyImpl(this._value);

  final PreferenceResponse _value;

  @override
  PreferenceResponse dislikedFoods(List<String>? dislikedFoods) =>
      this(dislikedFoods: dislikedFoods);

  @override
  PreferenceResponse allergies(List<String>? allergies) =>
      this(allergies: allergies);

  @override
  PreferenceResponse dietaryConstraints(List<String>? dietaryConstraints) =>
      this(dietaryConstraints: dietaryConstraints);

  @override
  PreferenceResponse mealPreferences(Map<String, Object>? mealPreferences) =>
      this(mealPreferences: mealPreferences);

  @override
  PreferenceResponse trainingPreferences(
    Map<String, Object>? trainingPreferences,
  ) => this(trainingPreferences: trainingPreferences);

  @override
  PreferenceResponse preferredTrainingTime(String? preferredTrainingTime) =>
      this(preferredTrainingTime: preferredTrainingTime);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceResponse call({
    Object? dislikedFoods = const $CopyWithPlaceholder(),
    Object? allergies = const $CopyWithPlaceholder(),
    Object? dietaryConstraints = const $CopyWithPlaceholder(),
    Object? mealPreferences = const $CopyWithPlaceholder(),
    Object? trainingPreferences = const $CopyWithPlaceholder(),
    Object? preferredTrainingTime = const $CopyWithPlaceholder(),
  }) {
    return PreferenceResponse(
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

extension $PreferenceResponseCopyWith on PreferenceResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPreferenceResponse.copyWith(...)` or like so:`instanceOfPreferenceResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferenceResponseCWProxy get copyWith =>
      _$PreferenceResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferenceResponse _$PreferenceResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PreferenceResponse', json, ($checkedConvert) {
  final val = PreferenceResponse(
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

Map<String, dynamic> _$PreferenceResponseToJson(PreferenceResponse instance) =>
    <String, dynamic>{
      'dislikedFoods': ?instance.dislikedFoods,
      'allergies': ?instance.allergies,
      'dietaryConstraints': ?instance.dietaryConstraints,
      'mealPreferences': ?instance.mealPreferences,
      'trainingPreferences': ?instance.trainingPreferences,
      'preferredTrainingTime': ?instance.preferredTrainingTime,
    };
