// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_apply_schedule_proposal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseApplyScheduleProposalResponseCWProxy {
  ApiResponseApplyScheduleProposalResponse success(bool? success);

  ApiResponseApplyScheduleProposalResponse message(String? message);

  ApiResponseApplyScheduleProposalResponse data(
    ApplyScheduleProposalResponse? data,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseApplyScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseApplyScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseApplyScheduleProposalResponse call({
    bool? success,
    String? message,
    ApplyScheduleProposalResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseApplyScheduleProposalResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseApplyScheduleProposalResponse.copyWith.fieldName(...)`
class _$ApiResponseApplyScheduleProposalResponseCWProxyImpl
    implements _$ApiResponseApplyScheduleProposalResponseCWProxy {
  const _$ApiResponseApplyScheduleProposalResponseCWProxyImpl(this._value);

  final ApiResponseApplyScheduleProposalResponse _value;

  @override
  ApiResponseApplyScheduleProposalResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseApplyScheduleProposalResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseApplyScheduleProposalResponse data(
    ApplyScheduleProposalResponse? data,
  ) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseApplyScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseApplyScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseApplyScheduleProposalResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseApplyScheduleProposalResponse(
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
          : data as ApplyScheduleProposalResponse?,
    );
  }
}

extension $ApiResponseApplyScheduleProposalResponseCopyWith
    on ApiResponseApplyScheduleProposalResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseApplyScheduleProposalResponse.copyWith(...)` or like so:`instanceOfApiResponseApplyScheduleProposalResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseApplyScheduleProposalResponseCWProxy get copyWith =>
      _$ApiResponseApplyScheduleProposalResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseApplyScheduleProposalResponse
_$ApiResponseApplyScheduleProposalResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseApplyScheduleProposalResponse', json, (
      $checkedConvert,
    ) {
      final val = ApiResponseApplyScheduleProposalResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : ApplyScheduleProposalResponse.fromJson(
                  v as Map<String, dynamic>,
                ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseApplyScheduleProposalResponseToJson(
  ApiResponseApplyScheduleProposalResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
