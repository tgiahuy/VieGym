// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_schedule_proposal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseScheduleProposalResponseCWProxy {
  ApiResponseScheduleProposalResponse success(bool? success);

  ApiResponseScheduleProposalResponse message(String? message);

  ApiResponseScheduleProposalResponse data(ScheduleProposalResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseScheduleProposalResponse call({
    bool? success,
    String? message,
    ScheduleProposalResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseScheduleProposalResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseScheduleProposalResponse.copyWith.fieldName(...)`
class _$ApiResponseScheduleProposalResponseCWProxyImpl
    implements _$ApiResponseScheduleProposalResponseCWProxy {
  const _$ApiResponseScheduleProposalResponseCWProxyImpl(this._value);

  final ApiResponseScheduleProposalResponse _value;

  @override
  ApiResponseScheduleProposalResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseScheduleProposalResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseScheduleProposalResponse data(ScheduleProposalResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseScheduleProposalResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseScheduleProposalResponse(
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
          : data as ScheduleProposalResponse?,
    );
  }
}

extension $ApiResponseScheduleProposalResponseCopyWith
    on ApiResponseScheduleProposalResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseScheduleProposalResponse.copyWith(...)` or like so:`instanceOfApiResponseScheduleProposalResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseScheduleProposalResponseCWProxy get copyWith =>
      _$ApiResponseScheduleProposalResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseScheduleProposalResponse
_$ApiResponseScheduleProposalResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseScheduleProposalResponse', json, (
      $checkedConvert,
    ) {
      final val = ApiResponseScheduleProposalResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : ScheduleProposalResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseScheduleProposalResponseToJson(
  ApiResponseScheduleProposalResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
