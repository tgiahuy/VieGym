// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_health_profile_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateHealthProfileRequestCWProxy {
  UpdateHealthProfileRequest dateOfBirth(DateTime dateOfBirth);

  UpdateHealthProfileRequest gender(
    UpdateHealthProfileRequestGenderEnum gender,
  );

  UpdateHealthProfileRequest calculationSex(
    UpdateHealthProfileRequestCalculationSexEnum? calculationSex,
  );

  UpdateHealthProfileRequest heightCm(num heightCm);

  UpdateHealthProfileRequest activityLevel(
    UpdateHealthProfileRequestActivityLevelEnum activityLevel,
  );

  UpdateHealthProfileRequest fitnessGoal(
    UpdateHealthProfileRequestFitnessGoalEnum fitnessGoal,
  );

  UpdateHealthProfileRequest trainingExperience(
    UpdateHealthProfileRequestTrainingExperienceEnum trainingExperience,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateHealthProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateHealthProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateHealthProfileRequest call({
    DateTime dateOfBirth,
    UpdateHealthProfileRequestGenderEnum gender,
    UpdateHealthProfileRequestCalculationSexEnum? calculationSex,
    num heightCm,
    UpdateHealthProfileRequestActivityLevelEnum activityLevel,
    UpdateHealthProfileRequestFitnessGoalEnum fitnessGoal,
    UpdateHealthProfileRequestTrainingExperienceEnum trainingExperience,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateHealthProfileRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateHealthProfileRequest.copyWith.fieldName(...)`
class _$UpdateHealthProfileRequestCWProxyImpl
    implements _$UpdateHealthProfileRequestCWProxy {
  const _$UpdateHealthProfileRequestCWProxyImpl(this._value);

  final UpdateHealthProfileRequest _value;

  @override
  UpdateHealthProfileRequest dateOfBirth(DateTime dateOfBirth) =>
      this(dateOfBirth: dateOfBirth);

  @override
  UpdateHealthProfileRequest gender(
    UpdateHealthProfileRequestGenderEnum gender,
  ) => this(gender: gender);

  @override
  UpdateHealthProfileRequest calculationSex(
    UpdateHealthProfileRequestCalculationSexEnum? calculationSex,
  ) => this(calculationSex: calculationSex);

  @override
  UpdateHealthProfileRequest heightCm(num heightCm) => this(heightCm: heightCm);

  @override
  UpdateHealthProfileRequest activityLevel(
    UpdateHealthProfileRequestActivityLevelEnum activityLevel,
  ) => this(activityLevel: activityLevel);

  @override
  UpdateHealthProfileRequest fitnessGoal(
    UpdateHealthProfileRequestFitnessGoalEnum fitnessGoal,
  ) => this(fitnessGoal: fitnessGoal);

  @override
  UpdateHealthProfileRequest trainingExperience(
    UpdateHealthProfileRequestTrainingExperienceEnum trainingExperience,
  ) => this(trainingExperience: trainingExperience);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateHealthProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateHealthProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateHealthProfileRequest call({
    Object? dateOfBirth = const $CopyWithPlaceholder(),
    Object? gender = const $CopyWithPlaceholder(),
    Object? calculationSex = const $CopyWithPlaceholder(),
    Object? heightCm = const $CopyWithPlaceholder(),
    Object? activityLevel = const $CopyWithPlaceholder(),
    Object? fitnessGoal = const $CopyWithPlaceholder(),
    Object? trainingExperience = const $CopyWithPlaceholder(),
  }) {
    return UpdateHealthProfileRequest(
      dateOfBirth: dateOfBirth == const $CopyWithPlaceholder()
          ? _value.dateOfBirth
          // ignore: cast_nullable_to_non_nullable
          : dateOfBirth as DateTime,
      gender: gender == const $CopyWithPlaceholder()
          ? _value.gender
          // ignore: cast_nullable_to_non_nullable
          : gender as UpdateHealthProfileRequestGenderEnum,
      calculationSex: calculationSex == const $CopyWithPlaceholder()
          ? _value.calculationSex
          // ignore: cast_nullable_to_non_nullable
          : calculationSex as UpdateHealthProfileRequestCalculationSexEnum?,
      heightCm: heightCm == const $CopyWithPlaceholder()
          ? _value.heightCm
          // ignore: cast_nullable_to_non_nullable
          : heightCm as num,
      activityLevel: activityLevel == const $CopyWithPlaceholder()
          ? _value.activityLevel
          // ignore: cast_nullable_to_non_nullable
          : activityLevel as UpdateHealthProfileRequestActivityLevelEnum,
      fitnessGoal: fitnessGoal == const $CopyWithPlaceholder()
          ? _value.fitnessGoal
          // ignore: cast_nullable_to_non_nullable
          : fitnessGoal as UpdateHealthProfileRequestFitnessGoalEnum,
      trainingExperience: trainingExperience == const $CopyWithPlaceholder()
          ? _value.trainingExperience
          // ignore: cast_nullable_to_non_nullable
          : trainingExperience
                as UpdateHealthProfileRequestTrainingExperienceEnum,
    );
  }
}

extension $UpdateHealthProfileRequestCopyWith on UpdateHealthProfileRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateHealthProfileRequest.copyWith(...)` or like so:`instanceOfUpdateHealthProfileRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateHealthProfileRequestCWProxy get copyWith =>
      _$UpdateHealthProfileRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHealthProfileRequest _$UpdateHealthProfileRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateHealthProfileRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'dateOfBirth',
      'gender',
      'heightCm',
      'activityLevel',
      'fitnessGoal',
      'trainingExperience',
    ],
  );
  final val = UpdateHealthProfileRequest(
    dateOfBirth: $checkedConvert(
      'dateOfBirth',
      (v) => DateTime.parse(v as String),
    ),
    gender: $checkedConvert(
      'gender',
      (v) => $enumDecode(_$UpdateHealthProfileRequestGenderEnumEnumMap, v),
    ),
    calculationSex: $checkedConvert(
      'calculationSex',
      (v) => $enumDecodeNullable(
        _$UpdateHealthProfileRequestCalculationSexEnumEnumMap,
        v,
      ),
    ),
    heightCm: $checkedConvert('heightCm', (v) => v as num),
    activityLevel: $checkedConvert(
      'activityLevel',
      (v) =>
          $enumDecode(_$UpdateHealthProfileRequestActivityLevelEnumEnumMap, v),
    ),
    fitnessGoal: $checkedConvert(
      'fitnessGoal',
      (v) => $enumDecode(_$UpdateHealthProfileRequestFitnessGoalEnumEnumMap, v),
    ),
    trainingExperience: $checkedConvert(
      'trainingExperience',
      (v) => $enumDecode(
        _$UpdateHealthProfileRequestTrainingExperienceEnumEnumMap,
        v,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateHealthProfileRequestToJson(
  UpdateHealthProfileRequest instance,
) => <String, dynamic>{
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'gender': _$UpdateHealthProfileRequestGenderEnumEnumMap[instance.gender]!,
  'calculationSex':
      ?_$UpdateHealthProfileRequestCalculationSexEnumEnumMap[instance
          .calculationSex],
  'heightCm': instance.heightCm,
  'activityLevel':
      _$UpdateHealthProfileRequestActivityLevelEnumEnumMap[instance
          .activityLevel]!,
  'fitnessGoal':
      _$UpdateHealthProfileRequestFitnessGoalEnumEnumMap[instance.fitnessGoal]!,
  'trainingExperience':
      _$UpdateHealthProfileRequestTrainingExperienceEnumEnumMap[instance
          .trainingExperience]!,
};

const _$UpdateHealthProfileRequestGenderEnumEnumMap = {
  UpdateHealthProfileRequestGenderEnum.MALE: 'MALE',
  UpdateHealthProfileRequestGenderEnum.FEMALE: 'FEMALE',
  UpdateHealthProfileRequestGenderEnum.OTHER: 'OTHER',
  UpdateHealthProfileRequestGenderEnum.UNSPECIFIED: 'UNSPECIFIED',
};

const _$UpdateHealthProfileRequestCalculationSexEnumEnumMap = {
  UpdateHealthProfileRequestCalculationSexEnum.MALE: 'MALE',
  UpdateHealthProfileRequestCalculationSexEnum.FEMALE: 'FEMALE',
  UpdateHealthProfileRequestCalculationSexEnum.UNSPECIFIED: 'UNSPECIFIED',
};

const _$UpdateHealthProfileRequestActivityLevelEnumEnumMap = {
  UpdateHealthProfileRequestActivityLevelEnum.SEDENTARY: 'SEDENTARY',
  UpdateHealthProfileRequestActivityLevelEnum.LIGHT: 'LIGHT',
  UpdateHealthProfileRequestActivityLevelEnum.MODERATE: 'MODERATE',
  UpdateHealthProfileRequestActivityLevelEnum.ACTIVE: 'ACTIVE',
  UpdateHealthProfileRequestActivityLevelEnum.VERY_ACTIVE: 'VERY_ACTIVE',
};

const _$UpdateHealthProfileRequestFitnessGoalEnumEnumMap = {
  UpdateHealthProfileRequestFitnessGoalEnum.LOSE_WEIGHT: 'LOSE_WEIGHT',
  UpdateHealthProfileRequestFitnessGoalEnum.MAINTAIN_WEIGHT: 'MAINTAIN_WEIGHT',
  UpdateHealthProfileRequestFitnessGoalEnum.GAIN_WEIGHT: 'GAIN_WEIGHT',
  UpdateHealthProfileRequestFitnessGoalEnum.GAIN_MUSCLE: 'GAIN_MUSCLE',
};

const _$UpdateHealthProfileRequestTrainingExperienceEnumEnumMap = {
  UpdateHealthProfileRequestTrainingExperienceEnum.BEGINNER: 'BEGINNER',
  UpdateHealthProfileRequestTrainingExperienceEnum.INTERMEDIATE: 'INTERMEDIATE',
  UpdateHealthProfileRequestTrainingExperienceEnum.ADVANCED: 'ADVANCED',
};
