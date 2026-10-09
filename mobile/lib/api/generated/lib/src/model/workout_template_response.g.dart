// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutTemplateResponseCWProxy {
  WorkoutTemplateResponse id(int? id);

  WorkoutTemplateResponse name(String? name);

  WorkoutTemplateResponse programType(String? programType);

  WorkoutTemplateResponse description(String? description);

  WorkoutTemplateResponse difficulty(String? difficulty);

  WorkoutTemplateResponse goal(String? goal);

  WorkoutTemplateResponse status(String? status);

  WorkoutTemplateResponse version(int? version);

  WorkoutTemplateResponse days(List<WorkoutTemplateDayResponse>? days);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateResponse call({
    int? id,
    String? name,
    String? programType,
    String? description,
    String? difficulty,
    String? goal,
    String? status,
    int? version,
    List<WorkoutTemplateDayResponse>? days,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutTemplateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutTemplateResponse.copyWith.fieldName(...)`
class _$WorkoutTemplateResponseCWProxyImpl
    implements _$WorkoutTemplateResponseCWProxy {
  const _$WorkoutTemplateResponseCWProxyImpl(this._value);

  final WorkoutTemplateResponse _value;

  @override
  WorkoutTemplateResponse id(int? id) => this(id: id);

  @override
  WorkoutTemplateResponse name(String? name) => this(name: name);

  @override
  WorkoutTemplateResponse programType(String? programType) =>
      this(programType: programType);

  @override
  WorkoutTemplateResponse description(String? description) =>
      this(description: description);

  @override
  WorkoutTemplateResponse difficulty(String? difficulty) =>
      this(difficulty: difficulty);

  @override
  WorkoutTemplateResponse goal(String? goal) => this(goal: goal);

  @override
  WorkoutTemplateResponse status(String? status) => this(status: status);

  @override
  WorkoutTemplateResponse version(int? version) => this(version: version);

  @override
  WorkoutTemplateResponse days(List<WorkoutTemplateDayResponse>? days) =>
      this(days: days);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? programType = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? difficulty = const $CopyWithPlaceholder(),
    Object? goal = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? days = const $CopyWithPlaceholder(),
  }) {
    return WorkoutTemplateResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
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
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int?,
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as List<WorkoutTemplateDayResponse>?,
    );
  }
}

extension $WorkoutTemplateResponseCopyWith on WorkoutTemplateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutTemplateResponse.copyWith(...)` or like so:`instanceOfWorkoutTemplateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutTemplateResponseCWProxy get copyWith =>
      _$WorkoutTemplateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutTemplateResponse _$WorkoutTemplateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutTemplateResponse', json, ($checkedConvert) {
  final val = WorkoutTemplateResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String?),
    programType: $checkedConvert('programType', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    difficulty: $checkedConvert('difficulty', (v) => v as String?),
    goal: $checkedConvert('goal', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
    version: $checkedConvert('version', (v) => (v as num?)?.toInt()),
    days: $checkedConvert(
      'days',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                WorkoutTemplateDayResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutTemplateResponseToJson(
  WorkoutTemplateResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'programType': ?instance.programType,
  'description': ?instance.description,
  'difficulty': ?instance.difficulty,
  'goal': ?instance.goal,
  'status': ?instance.status,
  'version': ?instance.version,
  'days': ?instance.days?.map((e) => e.toJson()).toList(),
};
