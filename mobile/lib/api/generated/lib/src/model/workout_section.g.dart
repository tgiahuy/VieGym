// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_section.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutSectionCWProxy {
  WorkoutSection today(List<Object>? today);

  WorkoutSection next(Object? next);

  WorkoutSection completion(WorkoutCompletion? completion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSection(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSection call({
    List<Object>? today,
    Object? next,
    WorkoutCompletion? completion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutSection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutSection.copyWith.fieldName(...)`
class _$WorkoutSectionCWProxyImpl implements _$WorkoutSectionCWProxy {
  const _$WorkoutSectionCWProxyImpl(this._value);

  final WorkoutSection _value;

  @override
  WorkoutSection today(List<Object>? today) => this(today: today);

  @override
  WorkoutSection next(Object? next) => this(next: next);

  @override
  WorkoutSection completion(WorkoutCompletion? completion) =>
      this(completion: completion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSection(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSection call({
    Object? today = const $CopyWithPlaceholder(),
    Object? next = const $CopyWithPlaceholder(),
    Object? completion = const $CopyWithPlaceholder(),
  }) {
    return WorkoutSection(
      today: today == const $CopyWithPlaceholder()
          ? _value.today
          // ignore: cast_nullable_to_non_nullable
          : today as List<Object>?,
      next: next == const $CopyWithPlaceholder()
          ? _value.next
          // ignore: cast_nullable_to_non_nullable
          : next as Object?,
      completion: completion == const $CopyWithPlaceholder()
          ? _value.completion
          // ignore: cast_nullable_to_non_nullable
          : completion as WorkoutCompletion?,
    );
  }
}

extension $WorkoutSectionCopyWith on WorkoutSection {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutSection.copyWith(...)` or like so:`instanceOfWorkoutSection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutSectionCWProxy get copyWith => _$WorkoutSectionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSection _$WorkoutSectionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutSection', json, ($checkedConvert) {
      final val = WorkoutSection(
        today: $checkedConvert(
          'today',
          (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList(),
        ),
        next: $checkedConvert('next', (v) => v),
        completion: $checkedConvert(
          'completion',
          (v) => v == null
              ? null
              : WorkoutCompletion.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutSectionToJson(WorkoutSection instance) =>
    <String, dynamic>{
      'today': ?instance.today,
      'next': ?instance.next,
      'completion': ?instance.completion?.toJson(),
    };
