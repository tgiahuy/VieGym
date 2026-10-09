// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_muscle_group_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseMuscleGroupDtoCWProxy {
  ExerciseMuscleGroupDto id(int? id);

  ExerciseMuscleGroupDto code(String? code);

  ExerciseMuscleGroupDto name(String? name);

  ExerciseMuscleGroupDto role(String? role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseMuscleGroupDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseMuscleGroupDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseMuscleGroupDto call({
    int? id,
    String? code,
    String? name,
    String? role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExerciseMuscleGroupDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExerciseMuscleGroupDto.copyWith.fieldName(...)`
class _$ExerciseMuscleGroupDtoCWProxyImpl
    implements _$ExerciseMuscleGroupDtoCWProxy {
  const _$ExerciseMuscleGroupDtoCWProxyImpl(this._value);

  final ExerciseMuscleGroupDto _value;

  @override
  ExerciseMuscleGroupDto id(int? id) => this(id: id);

  @override
  ExerciseMuscleGroupDto code(String? code) => this(code: code);

  @override
  ExerciseMuscleGroupDto name(String? name) => this(name: name);

  @override
  ExerciseMuscleGroupDto role(String? role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseMuscleGroupDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseMuscleGroupDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseMuscleGroupDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return ExerciseMuscleGroupDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String?,
    );
  }
}

extension $ExerciseMuscleGroupDtoCopyWith on ExerciseMuscleGroupDto {
  /// Returns a callable class that can be used as follows: `instanceOfExerciseMuscleGroupDto.copyWith(...)` or like so:`instanceOfExerciseMuscleGroupDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExerciseMuscleGroupDtoCWProxy get copyWith =>
      _$ExerciseMuscleGroupDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseMuscleGroupDto _$ExerciseMuscleGroupDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExerciseMuscleGroupDto', json, ($checkedConvert) {
  final val = ExerciseMuscleGroupDto(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    code: $checkedConvert('code', (v) => v as String?),
    name: $checkedConvert('name', (v) => v as String?),
    role: $checkedConvert('role', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ExerciseMuscleGroupDtoToJson(
  ExerciseMuscleGroupDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'code': ?instance.code,
  'name': ?instance.name,
  'role': ?instance.role,
};
