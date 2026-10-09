// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_equipment_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseEquipmentDtoCWProxy {
  ExerciseEquipmentDto id(int? id);

  ExerciseEquipmentDto code(String? code);

  ExerciseEquipmentDto name(String? name);

  ExerciseEquipmentDto required_(bool? required_);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseEquipmentDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseEquipmentDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseEquipmentDto call({
    int? id,
    String? code,
    String? name,
    bool? required_,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExerciseEquipmentDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExerciseEquipmentDto.copyWith.fieldName(...)`
class _$ExerciseEquipmentDtoCWProxyImpl
    implements _$ExerciseEquipmentDtoCWProxy {
  const _$ExerciseEquipmentDtoCWProxyImpl(this._value);

  final ExerciseEquipmentDto _value;

  @override
  ExerciseEquipmentDto id(int? id) => this(id: id);

  @override
  ExerciseEquipmentDto code(String? code) => this(code: code);

  @override
  ExerciseEquipmentDto name(String? name) => this(name: name);

  @override
  ExerciseEquipmentDto required_(bool? required_) => this(required_: required_);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseEquipmentDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseEquipmentDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseEquipmentDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? required_ = const $CopyWithPlaceholder(),
  }) {
    return ExerciseEquipmentDto(
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
      required_: required_ == const $CopyWithPlaceholder()
          ? _value.required_
          // ignore: cast_nullable_to_non_nullable
          : required_ as bool?,
    );
  }
}

extension $ExerciseEquipmentDtoCopyWith on ExerciseEquipmentDto {
  /// Returns a callable class that can be used as follows: `instanceOfExerciseEquipmentDto.copyWith(...)` or like so:`instanceOfExerciseEquipmentDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExerciseEquipmentDtoCWProxy get copyWith =>
      _$ExerciseEquipmentDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseEquipmentDto _$ExerciseEquipmentDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExerciseEquipmentDto', json, ($checkedConvert) {
  final val = ExerciseEquipmentDto(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    code: $checkedConvert('code', (v) => v as String?),
    name: $checkedConvert('name', (v) => v as String?),
    required_: $checkedConvert('required', (v) => v as bool?),
  );
  return val;
}, fieldKeyMap: const {'required_': 'required'});

Map<String, dynamic> _$ExerciseEquipmentDtoToJson(
  ExerciseEquipmentDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'code': ?instance.code,
  'name': ?instance.name,
  'required': ?instance.required_,
};
