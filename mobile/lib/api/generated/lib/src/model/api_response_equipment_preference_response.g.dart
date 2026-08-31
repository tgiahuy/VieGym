// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_equipment_preference_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseEquipmentPreferenceResponseCWProxy {
  ApiResponseEquipmentPreferenceResponse success(bool? success);

  ApiResponseEquipmentPreferenceResponse message(String? message);

  ApiResponseEquipmentPreferenceResponse data(
    EquipmentPreferenceResponse? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseEquipmentPreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseEquipmentPreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseEquipmentPreferenceResponse call({
    bool? success,
    String? message,
    EquipmentPreferenceResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseEquipmentPreferenceResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseEquipmentPreferenceResponse.copyWith.fieldName(...)`
class _$ApiResponseEquipmentPreferenceResponseCWProxyImpl
    implements _$ApiResponseEquipmentPreferenceResponseCWProxy {
  const _$ApiResponseEquipmentPreferenceResponseCWProxyImpl(this._value);

  final ApiResponseEquipmentPreferenceResponse _value;

  @override
  ApiResponseEquipmentPreferenceResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseEquipmentPreferenceResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseEquipmentPreferenceResponse data(
    EquipmentPreferenceResponse? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseEquipmentPreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseEquipmentPreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseEquipmentPreferenceResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseEquipmentPreferenceResponse(
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
          : data as EquipmentPreferenceResponse?,
    );
  }
}

extension $ApiResponseEquipmentPreferenceResponseCopyWith
    on ApiResponseEquipmentPreferenceResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseEquipmentPreferenceResponse.copyWith(...)` or like so:`instanceOfApiResponseEquipmentPreferenceResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseEquipmentPreferenceResponseCWProxy get copyWith =>
      _$ApiResponseEquipmentPreferenceResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseEquipmentPreferenceResponse
_$ApiResponseEquipmentPreferenceResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseEquipmentPreferenceResponse', json, (
      $checkedConvert,
    ) {
      final val = ApiResponseEquipmentPreferenceResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : EquipmentPreferenceResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseEquipmentPreferenceResponseToJson(
  ApiResponseEquipmentPreferenceResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
