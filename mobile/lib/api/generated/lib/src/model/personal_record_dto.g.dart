// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PersonalRecordDtoCWProxy {
  PersonalRecordDto id(int? id);

  PersonalRecordDto exerciseId(int? exerciseId);

  PersonalRecordDto exerciseName(String? exerciseName);

  PersonalRecordDto recordType(String? recordType);

  PersonalRecordDto value(double? value);

  PersonalRecordDto achievedAt(DateTime? achievedAt);

  PersonalRecordDto workoutLogId(int? workoutLogId);

  PersonalRecordDto previousValue(double? previousValue);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PersonalRecordDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PersonalRecordDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PersonalRecordDto call({
    int? id,
    int? exerciseId,
    String? exerciseName,
    String? recordType,
    double? value,
    DateTime? achievedAt,
    int? workoutLogId,
    double? previousValue,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPersonalRecordDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPersonalRecordDto.copyWith.fieldName(...)`
class _$PersonalRecordDtoCWProxyImpl implements _$PersonalRecordDtoCWProxy {
  const _$PersonalRecordDtoCWProxyImpl(this._value);

  final PersonalRecordDto _value;

  @override
  PersonalRecordDto id(int? id) => this(id: id);

  @override
  PersonalRecordDto exerciseId(int? exerciseId) => this(exerciseId: exerciseId);

  @override
  PersonalRecordDto exerciseName(String? exerciseName) =>
      this(exerciseName: exerciseName);

  @override
  PersonalRecordDto recordType(String? recordType) =>
      this(recordType: recordType);

  @override
  PersonalRecordDto value(double? value) => this(value: value);

  @override
  PersonalRecordDto achievedAt(DateTime? achievedAt) =>
      this(achievedAt: achievedAt);

  @override
  PersonalRecordDto workoutLogId(int? workoutLogId) =>
      this(workoutLogId: workoutLogId);

  @override
  PersonalRecordDto previousValue(double? previousValue) =>
      this(previousValue: previousValue);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PersonalRecordDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PersonalRecordDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PersonalRecordDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? exerciseName = const $CopyWithPlaceholder(),
    Object? recordType = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? achievedAt = const $CopyWithPlaceholder(),
    Object? workoutLogId = const $CopyWithPlaceholder(),
    Object? previousValue = const $CopyWithPlaceholder(),
  }) {
    return PersonalRecordDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as int?,
      exerciseName: exerciseName == const $CopyWithPlaceholder()
          ? _value.exerciseName
          // ignore: cast_nullable_to_non_nullable
          : exerciseName as String?,
      recordType: recordType == const $CopyWithPlaceholder()
          ? _value.recordType
          // ignore: cast_nullable_to_non_nullable
          : recordType as String?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as double?,
      achievedAt: achievedAt == const $CopyWithPlaceholder()
          ? _value.achievedAt
          // ignore: cast_nullable_to_non_nullable
          : achievedAt as DateTime?,
      workoutLogId: workoutLogId == const $CopyWithPlaceholder()
          ? _value.workoutLogId
          // ignore: cast_nullable_to_non_nullable
          : workoutLogId as int?,
      previousValue: previousValue == const $CopyWithPlaceholder()
          ? _value.previousValue
          // ignore: cast_nullable_to_non_nullable
          : previousValue as double?,
    );
  }
}

extension $PersonalRecordDtoCopyWith on PersonalRecordDto {
  /// Returns a callable class that can be used as follows: `instanceOfPersonalRecordDto.copyWith(...)` or like so:`instanceOfPersonalRecordDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PersonalRecordDtoCWProxy get copyWith =>
      _$PersonalRecordDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalRecordDto _$PersonalRecordDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PersonalRecordDto', json, ($checkedConvert) {
      final val = PersonalRecordDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        exerciseId: $checkedConvert('exerciseId', (v) => (v as num?)?.toInt()),
        exerciseName: $checkedConvert('exerciseName', (v) => v as String?),
        recordType: $checkedConvert('recordType', (v) => v as String?),
        value: $checkedConvert('value', (v) => (v as num?)?.toDouble()),
        achievedAt: $checkedConvert(
          'achievedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        workoutLogId: $checkedConvert(
          'workoutLogId',
          (v) => (v as num?)?.toInt(),
        ),
        previousValue: $checkedConvert(
          'previousValue',
          (v) => (v as num?)?.toDouble(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PersonalRecordDtoToJson(PersonalRecordDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'exerciseId': ?instance.exerciseId,
      'exerciseName': ?instance.exerciseName,
      'recordType': ?instance.recordType,
      'value': ?instance.value,
      'achievedAt': ?instance.achievedAt?.toIso8601String(),
      'workoutLogId': ?instance.workoutLogId,
      'previousValue': ?instance.previousValue,
    };
