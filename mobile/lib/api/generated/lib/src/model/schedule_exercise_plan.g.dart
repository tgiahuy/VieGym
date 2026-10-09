// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_exercise_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScheduleExercisePlanCWProxy {
  ScheduleExercisePlan exerciseId(int? exerciseId);

  ScheduleExercisePlan sortOrder(int? sortOrder);

  ScheduleExercisePlan targetSets(int? targetSets);

  ScheduleExercisePlan targetRepsMin(int? targetRepsMin);

  ScheduleExercisePlan targetRepsMax(int? targetRepsMax);

  ScheduleExercisePlan targetDurationSeconds(int? targetDurationSeconds);

  ScheduleExercisePlan restSeconds(int? restSeconds);

  ScheduleExercisePlan note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleExercisePlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleExercisePlan(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleExercisePlan call({
    int? exerciseId,
    int? sortOrder,
    int? targetSets,
    int? targetRepsMin,
    int? targetRepsMax,
    int? targetDurationSeconds,
    int? restSeconds,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScheduleExercisePlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScheduleExercisePlan.copyWith.fieldName(...)`
class _$ScheduleExercisePlanCWProxyImpl
    implements _$ScheduleExercisePlanCWProxy {
  const _$ScheduleExercisePlanCWProxyImpl(this._value);

  final ScheduleExercisePlan _value;

  @override
  ScheduleExercisePlan exerciseId(int? exerciseId) =>
      this(exerciseId: exerciseId);

  @override
  ScheduleExercisePlan sortOrder(int? sortOrder) => this(sortOrder: sortOrder);

  @override
  ScheduleExercisePlan targetSets(int? targetSets) =>
      this(targetSets: targetSets);

  @override
  ScheduleExercisePlan targetRepsMin(int? targetRepsMin) =>
      this(targetRepsMin: targetRepsMin);

  @override
  ScheduleExercisePlan targetRepsMax(int? targetRepsMax) =>
      this(targetRepsMax: targetRepsMax);

  @override
  ScheduleExercisePlan targetDurationSeconds(int? targetDurationSeconds) =>
      this(targetDurationSeconds: targetDurationSeconds);

  @override
  ScheduleExercisePlan restSeconds(int? restSeconds) =>
      this(restSeconds: restSeconds);

  @override
  ScheduleExercisePlan note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleExercisePlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleExercisePlan(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleExercisePlan call({
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? targetSets = const $CopyWithPlaceholder(),
    Object? targetRepsMin = const $CopyWithPlaceholder(),
    Object? targetRepsMax = const $CopyWithPlaceholder(),
    Object? targetDurationSeconds = const $CopyWithPlaceholder(),
    Object? restSeconds = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return ScheduleExercisePlan(
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as int?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      targetSets: targetSets == const $CopyWithPlaceholder()
          ? _value.targetSets
          // ignore: cast_nullable_to_non_nullable
          : targetSets as int?,
      targetRepsMin: targetRepsMin == const $CopyWithPlaceholder()
          ? _value.targetRepsMin
          // ignore: cast_nullable_to_non_nullable
          : targetRepsMin as int?,
      targetRepsMax: targetRepsMax == const $CopyWithPlaceholder()
          ? _value.targetRepsMax
          // ignore: cast_nullable_to_non_nullable
          : targetRepsMax as int?,
      targetDurationSeconds:
          targetDurationSeconds == const $CopyWithPlaceholder()
          ? _value.targetDurationSeconds
          // ignore: cast_nullable_to_non_nullable
          : targetDurationSeconds as int?,
      restSeconds: restSeconds == const $CopyWithPlaceholder()
          ? _value.restSeconds
          // ignore: cast_nullable_to_non_nullable
          : restSeconds as int?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $ScheduleExercisePlanCopyWith on ScheduleExercisePlan {
  /// Returns a callable class that can be used as follows: `instanceOfScheduleExercisePlan.copyWith(...)` or like so:`instanceOfScheduleExercisePlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScheduleExercisePlanCWProxy get copyWith =>
      _$ScheduleExercisePlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleExercisePlan _$ScheduleExercisePlanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ScheduleExercisePlan', json, ($checkedConvert) {
  final val = ScheduleExercisePlan(
    exerciseId: $checkedConvert('exerciseId', (v) => (v as num?)?.toInt()),
    sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
    targetSets: $checkedConvert('targetSets', (v) => (v as num?)?.toInt()),
    targetRepsMin: $checkedConvert(
      'targetRepsMin',
      (v) => (v as num?)?.toInt(),
    ),
    targetRepsMax: $checkedConvert(
      'targetRepsMax',
      (v) => (v as num?)?.toInt(),
    ),
    targetDurationSeconds: $checkedConvert(
      'targetDurationSeconds',
      (v) => (v as num?)?.toInt(),
    ),
    restSeconds: $checkedConvert('restSeconds', (v) => (v as num?)?.toInt()),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ScheduleExercisePlanToJson(
  ScheduleExercisePlan instance,
) => <String, dynamic>{
  'exerciseId': ?instance.exerciseId,
  'sortOrder': ?instance.sortOrder,
  'targetSets': ?instance.targetSets,
  'targetRepsMin': ?instance.targetRepsMin,
  'targetRepsMax': ?instance.targetRepsMax,
  'targetDurationSeconds': ?instance.targetDurationSeconds,
  'restSeconds': ?instance.restSeconds,
  'note': ?instance.note,
};
