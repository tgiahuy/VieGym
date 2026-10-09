// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_completion.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutCompletionCWProxy {
  WorkoutCompletion windowFrom(DateTime? windowFrom);

  WorkoutCompletion windowTo(DateTime? windowTo);

  WorkoutCompletion scheduledEligible(int? scheduledEligible);

  WorkoutCompletion completedEligible(int? completedEligible);

  WorkoutCompletion rate(num? rate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutCompletion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutCompletion(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutCompletion call({
    DateTime? windowFrom,
    DateTime? windowTo,
    int? scheduledEligible,
    int? completedEligible,
    num? rate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutCompletion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutCompletion.copyWith.fieldName(...)`
class _$WorkoutCompletionCWProxyImpl implements _$WorkoutCompletionCWProxy {
  const _$WorkoutCompletionCWProxyImpl(this._value);

  final WorkoutCompletion _value;

  @override
  WorkoutCompletion windowFrom(DateTime? windowFrom) =>
      this(windowFrom: windowFrom);

  @override
  WorkoutCompletion windowTo(DateTime? windowTo) => this(windowTo: windowTo);

  @override
  WorkoutCompletion scheduledEligible(int? scheduledEligible) =>
      this(scheduledEligible: scheduledEligible);

  @override
  WorkoutCompletion completedEligible(int? completedEligible) =>
      this(completedEligible: completedEligible);

  @override
  WorkoutCompletion rate(num? rate) => this(rate: rate);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutCompletion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutCompletion(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutCompletion call({
    Object? windowFrom = const $CopyWithPlaceholder(),
    Object? windowTo = const $CopyWithPlaceholder(),
    Object? scheduledEligible = const $CopyWithPlaceholder(),
    Object? completedEligible = const $CopyWithPlaceholder(),
    Object? rate = const $CopyWithPlaceholder(),
  }) {
    return WorkoutCompletion(
      windowFrom: windowFrom == const $CopyWithPlaceholder()
          ? _value.windowFrom
          // ignore: cast_nullable_to_non_nullable
          : windowFrom as DateTime?,
      windowTo: windowTo == const $CopyWithPlaceholder()
          ? _value.windowTo
          // ignore: cast_nullable_to_non_nullable
          : windowTo as DateTime?,
      scheduledEligible: scheduledEligible == const $CopyWithPlaceholder()
          ? _value.scheduledEligible
          // ignore: cast_nullable_to_non_nullable
          : scheduledEligible as int?,
      completedEligible: completedEligible == const $CopyWithPlaceholder()
          ? _value.completedEligible
          // ignore: cast_nullable_to_non_nullable
          : completedEligible as int?,
      rate: rate == const $CopyWithPlaceholder()
          ? _value.rate
          // ignore: cast_nullable_to_non_nullable
          : rate as num?,
    );
  }
}

extension $WorkoutCompletionCopyWith on WorkoutCompletion {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutCompletion.copyWith(...)` or like so:`instanceOfWorkoutCompletion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutCompletionCWProxy get copyWith =>
      _$WorkoutCompletionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutCompletion _$WorkoutCompletionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutCompletion', json, ($checkedConvert) {
      final val = WorkoutCompletion(
        windowFrom: $checkedConvert(
          'windowFrom',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        windowTo: $checkedConvert(
          'windowTo',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        scheduledEligible: $checkedConvert(
          'scheduledEligible',
          (v) => (v as num?)?.toInt(),
        ),
        completedEligible: $checkedConvert(
          'completedEligible',
          (v) => (v as num?)?.toInt(),
        ),
        rate: $checkedConvert('rate', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutCompletionToJson(WorkoutCompletion instance) =>
    <String, dynamic>{
      'windowFrom': ?instance.windowFrom?.toIso8601String(),
      'windowTo': ?instance.windowTo?.toIso8601String(),
      'scheduledEligible': ?instance.scheduledEligible,
      'completedEligible': ?instance.completedEligible,
      'rate': ?instance.rate,
    };
