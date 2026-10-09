// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_workout_program_summary_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseWorkoutProgramSummaryResponseCWProxy {
  ApiResponsePageResponseWorkoutProgramSummaryResponse success(bool? success);

  ApiResponsePageResponseWorkoutProgramSummaryResponse message(String? message);

  ApiResponsePageResponseWorkoutProgramSummaryResponse data(
    PageResponseWorkoutProgramSummaryResponse? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWorkoutProgramSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWorkoutProgramSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWorkoutProgramSummaryResponse call({
    bool? success,
    String? message,
    PageResponseWorkoutProgramSummaryResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseWorkoutProgramSummaryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseWorkoutProgramSummaryResponse.copyWith.fieldName(...)`
class _$ApiResponsePageResponseWorkoutProgramSummaryResponseCWProxyImpl
    implements _$ApiResponsePageResponseWorkoutProgramSummaryResponseCWProxy {
  const _$ApiResponsePageResponseWorkoutProgramSummaryResponseCWProxyImpl(
    this._value,
  );

  final ApiResponsePageResponseWorkoutProgramSummaryResponse _value;

  @override
  ApiResponsePageResponseWorkoutProgramSummaryResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponseWorkoutProgramSummaryResponse message(
    String? message,
  ) => this(message: message);

  @override
  ApiResponsePageResponseWorkoutProgramSummaryResponse data(
    PageResponseWorkoutProgramSummaryResponse? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseWorkoutProgramSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseWorkoutProgramSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseWorkoutProgramSummaryResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseWorkoutProgramSummaryResponse(
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
          : data as PageResponseWorkoutProgramSummaryResponse?,
    );
  }
}

extension $ApiResponsePageResponseWorkoutProgramSummaryResponseCopyWith
    on ApiResponsePageResponseWorkoutProgramSummaryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseWorkoutProgramSummaryResponse.copyWith(...)` or like so:`instanceOfApiResponsePageResponseWorkoutProgramSummaryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseWorkoutProgramSummaryResponseCWProxy get copyWith =>
      _$ApiResponsePageResponseWorkoutProgramSummaryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseWorkoutProgramSummaryResponse
_$ApiResponsePageResponseWorkoutProgramSummaryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ApiResponsePageResponseWorkoutProgramSummaryResponse',
  json,
  ($checkedConvert) {
    final val = ApiResponsePageResponseWorkoutProgramSummaryResponse(
      success: $checkedConvert('success', (v) => v as bool?),
      message: $checkedConvert('message', (v) => v as String?),
      data: $checkedConvert(
        'data',
        (v) => v == null
            ? null
            : PageResponseWorkoutProgramSummaryResponse.fromJson(
                v as Map<String, dynamic>,
              ),
      ),
    );
    return val;
  },
);

Map<String, dynamic>
_$ApiResponsePageResponseWorkoutProgramSummaryResponseToJson(
  ApiResponsePageResponseWorkoutProgramSummaryResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
