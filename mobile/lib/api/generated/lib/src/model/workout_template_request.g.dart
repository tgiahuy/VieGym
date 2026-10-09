// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutTemplateRequestCWProxy {
  WorkoutTemplateRequest name(String? name);

  WorkoutTemplateRequest programType(String? programType);

  WorkoutTemplateRequest description(String? description);

  WorkoutTemplateRequest difficulty(String? difficulty);

  WorkoutTemplateRequest goal(String? goal);

  WorkoutTemplateRequest status(String? status);

  WorkoutTemplateRequest days(List<WorkoutTemplateDayRequest>? days);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateRequest call({
    String? name,
    String? programType,
    String? description,
    String? difficulty,
    String? goal,
    String? status,
    List<WorkoutTemplateDayRequest>? days,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutTemplateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutTemplateRequest.copyWith.fieldName(...)`
class _$WorkoutTemplateRequestCWProxyImpl
    implements _$WorkoutTemplateRequestCWProxy {
  const _$WorkoutTemplateRequestCWProxyImpl(this._value);

  final WorkoutTemplateRequest _value;

  @override
  WorkoutTemplateRequest name(String? name) => this(name: name);

  @override
  WorkoutTemplateRequest programType(String? programType) =>
      this(programType: programType);

  @override
  WorkoutTemplateRequest description(String? description) =>
      this(description: description);

  @override
  WorkoutTemplateRequest difficulty(String? difficulty) =>
      this(difficulty: difficulty);

  @override
  WorkoutTemplateRequest goal(String? goal) => this(goal: goal);

  @override
  WorkoutTemplateRequest status(String? status) => this(status: status);

  @override
  WorkoutTemplateRequest days(List<WorkoutTemplateDayRequest>? days) =>
      this(days: days);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? programType = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? difficulty = const $CopyWithPlaceholder(),
    Object? goal = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? days = const $CopyWithPlaceholder(),
  }) {
    return WorkoutTemplateRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      programType: programType == const $CopyWithPlaceholder()
          ? _value.programType
          // ignore: cast_nullable_to_non_nullable
          : programType as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      difficulty: difficulty == const $CopyWithPlaceholder()
          ? _value.difficulty
          // ignore: cast_nullable_to_non_nullable
          : difficulty as String?,
      goal: goal == const $CopyWithPlaceholder()
          ? _value.goal
          // ignore: cast_nullable_to_non_nullable
          : goal as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as List<WorkoutTemplateDayRequest>?,
    );
  }
}

extension $WorkoutTemplateRequestCopyWith on WorkoutTemplateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutTemplateRequest.copyWith(...)` or like so:`instanceOfWorkoutTemplateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutTemplateRequestCWProxy get copyWith =>
      _$WorkoutTemplateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutTemplateRequest _$WorkoutTemplateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutTemplateRequest', json, ($checkedConvert) {
  final val = WorkoutTemplateRequest(
    name: $checkedConvert('name', (v) => v as String?),
    programType: $checkedConvert('programType', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    difficulty: $checkedConvert('difficulty', (v) => v as String?),
    goal: $checkedConvert('goal', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
    days: $checkedConvert(
      'days',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                WorkoutTemplateDayRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutTemplateRequestToJson(
  WorkoutTemplateRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'programType': ?instance.programType,
  'description': ?instance.description,
  'difficulty': ?instance.difficulty,
  'goal': ?instance.goal,
  'status': ?instance.status,
  'days': ?instance.days?.map((e) => e.toJson()).toList(),
};
