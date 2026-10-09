// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_list_muscle_group_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseListMuscleGroupDtoCWProxy {
  ApiResponseListMuscleGroupDto success(bool? success);

  ApiResponseListMuscleGroupDto message(String? message);

  ApiResponseListMuscleGroupDto data(List<MuscleGroupDto>? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListMuscleGroupDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListMuscleGroupDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListMuscleGroupDto call({
    bool? success,
    String? message,
    List<MuscleGroupDto>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseListMuscleGroupDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseListMuscleGroupDto.copyWith.fieldName(...)`
class _$ApiResponseListMuscleGroupDtoCWProxyImpl
    implements _$ApiResponseListMuscleGroupDtoCWProxy {
  const _$ApiResponseListMuscleGroupDtoCWProxyImpl(this._value);

  final ApiResponseListMuscleGroupDto _value;

  @override
  ApiResponseListMuscleGroupDto success(bool? success) =>
      this(success: success);

  @override
  ApiResponseListMuscleGroupDto message(String? message) =>
      this(message: message);

  @override
  ApiResponseListMuscleGroupDto data(List<MuscleGroupDto>? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListMuscleGroupDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListMuscleGroupDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListMuscleGroupDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseListMuscleGroupDto(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<MuscleGroupDto>?,
    );
  }
}

extension $ApiResponseListMuscleGroupDtoCopyWith
    on ApiResponseListMuscleGroupDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseListMuscleGroupDto.copyWith(...)` or like so:`instanceOfApiResponseListMuscleGroupDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseListMuscleGroupDtoCWProxy get copyWith =>
      _$ApiResponseListMuscleGroupDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseListMuscleGroupDto _$ApiResponseListMuscleGroupDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseListMuscleGroupDto', json, ($checkedConvert) {
  final val = ApiResponseListMuscleGroupDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)
          ?.map((e) => MuscleGroupDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseListMuscleGroupDtoToJson(
  ApiResponseListMuscleGroupDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.map((e) => e.toJson()).toList(),
};
