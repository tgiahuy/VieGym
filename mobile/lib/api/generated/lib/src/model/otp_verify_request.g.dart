// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpVerifyRequestCWProxy {
  OtpVerifyRequest challengeId(String? challengeId);

  OtpVerifyRequest purpose(OtpVerifyRequestPurposeEnum? purpose);

  OtpVerifyRequest code(String? code);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpVerifyRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpVerifyRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpVerifyRequest call({
    String? challengeId,
    OtpVerifyRequestPurposeEnum? purpose,
    String? code,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpVerifyRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpVerifyRequest.copyWith.fieldName(...)`
class _$OtpVerifyRequestCWProxyImpl implements _$OtpVerifyRequestCWProxy {
  const _$OtpVerifyRequestCWProxyImpl(this._value);

  final OtpVerifyRequest _value;

  @override
  OtpVerifyRequest challengeId(String? challengeId) =>
      this(challengeId: challengeId);

  @override
  OtpVerifyRequest purpose(OtpVerifyRequestPurposeEnum? purpose) =>
      this(purpose: purpose);

  @override
  OtpVerifyRequest code(String? code) => this(code: code);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpVerifyRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpVerifyRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpVerifyRequest call({
    Object? challengeId = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
  }) {
    return OtpVerifyRequest(
      challengeId: challengeId == const $CopyWithPlaceholder()
          ? _value.challengeId
          // ignore: cast_nullable_to_non_nullable
          : challengeId as String?,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as OtpVerifyRequestPurposeEnum?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
    );
  }
}

extension $OtpVerifyRequestCopyWith on OtpVerifyRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOtpVerifyRequest.copyWith(...)` or like so:`instanceOfOtpVerifyRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpVerifyRequestCWProxy get copyWith => _$OtpVerifyRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerifyRequest _$OtpVerifyRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpVerifyRequest', json, ($checkedConvert) {
      final val = OtpVerifyRequest(
        challengeId: $checkedConvert('challengeId', (v) => v as String?),
        purpose: $checkedConvert(
          'purpose',
          (v) => $enumDecodeNullable(_$OtpVerifyRequestPurposeEnumEnumMap, v),
        ),
        code: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$OtpVerifyRequestToJson(OtpVerifyRequest instance) =>
    <String, dynamic>{
      'challengeId': ?instance.challengeId,
      'purpose': ?_$OtpVerifyRequestPurposeEnumEnumMap[instance.purpose],
      'code': ?instance.code,
    };

const _$OtpVerifyRequestPurposeEnumEnumMap = {
  OtpVerifyRequestPurposeEnum.REGISTER: 'REGISTER',
  OtpVerifyRequestPurposeEnum.PASSWORD_RESET: 'PASSWORD_RESET',
};
