// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_group_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MuscleGroupDtoCWProxy {
  MuscleGroupDto id(int? id);

  MuscleGroupDto code(String? code);

  MuscleGroupDto name(String? name);

  MuscleGroupDto description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuscleGroupDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuscleGroupDto(...).copyWith(id: 12, name: "My name")
  /// ````
  MuscleGroupDto call({
    int? id,
    String? code,
    String? name,
    String? description,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMuscleGroupDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMuscleGroupDto.copyWith.fieldName(...)`
class _$MuscleGroupDtoCWProxyImpl implements _$MuscleGroupDtoCWProxy {
  const _$MuscleGroupDtoCWProxyImpl(this._value);

  final MuscleGroupDto _value;

  @override
  MuscleGroupDto id(int? id) => this(id: id);

  @override
  MuscleGroupDto code(String? code) => this(code: code);

  @override
  MuscleGroupDto name(String? name) => this(name: name);

  @override
  MuscleGroupDto description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MuscleGroupDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MuscleGroupDto(...).copyWith(id: 12, name: "My name")
  /// ````
  MuscleGroupDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return MuscleGroupDto(
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
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $MuscleGroupDtoCopyWith on MuscleGroupDto {
  /// Returns a callable class that can be used as follows: `instanceOfMuscleGroupDto.copyWith(...)` or like so:`instanceOfMuscleGroupDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MuscleGroupDtoCWProxy get copyWith => _$MuscleGroupDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MuscleGroupDto _$MuscleGroupDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MuscleGroupDto', json, ($checkedConvert) {
      final val = MuscleGroupDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        code: $checkedConvert('code', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MuscleGroupDtoToJson(MuscleGroupDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'code': ?instance.code,
      'name': ?instance.name,
      'description': ?instance.description,
    };
