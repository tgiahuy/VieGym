// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_resend_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpResendRequestCWProxy {
  OtpResendRequest challengeId(String? challengeId);

  OtpResendRequest purpose(OtpResendRequestPurposeEnum? purpose);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpResendRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpResendRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpResendRequest call({
    String? challengeId,
    OtpResendRequestPurposeEnum? purpose,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpResendRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpResendRequest.copyWith.fieldName(...)`
class _$OtpResendRequestCWProxyImpl implements _$OtpResendRequestCWProxy {
  const _$OtpResendRequestCWProxyImpl(this._value);

  final OtpResendRequest _value;

  @override
  OtpResendRequest challengeId(String? challengeId) =>
      this(challengeId: challengeId);

  @override
  OtpResendRequest purpose(OtpResendRequestPurposeEnum? purpose) =>
      this(purpose: purpose);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpResendRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpResendRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpResendRequest call({
    Object? challengeId = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
  }) {
    return OtpResendRequest(
      challengeId: challengeId == const $CopyWithPlaceholder()
          ? _value.challengeId
          // ignore: cast_nullable_to_non_nullable
          : challengeId as String?,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as OtpResendRequestPurposeEnum?,
    );
  }
}

extension $OtpResendRequestCopyWith on OtpResendRequest {
  /// Returns a callable class that can be used as follows: `instanceOfOtpResendRequest.copyWith(...)` or like so:`instanceOfOtpResendRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpResendRequestCWProxy get copyWith => _$OtpResendRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpResendRequest _$OtpResendRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpResendRequest', json, ($checkedConvert) {
      final val = OtpResendRequest(
        challengeId: $checkedConvert('challengeId', (v) => v as String?),
        purpose: $checkedConvert(
          'purpose',
          (v) => $enumDecodeNullable(_$OtpResendRequestPurposeEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$OtpResendRequestToJson(OtpResendRequest instance) =>
    <String, dynamic>{
      'challengeId': ?instance.challengeId,
      'purpose': ?_$OtpResendRequestPurposeEnumEnumMap[instance.purpose],
    };

const _$OtpResendRequestPurposeEnumEnumMap = {
  OtpResendRequestPurposeEnum.REGISTER: 'REGISTER',
  OtpResendRequestPurposeEnum.PASSWORD_RESET: 'PASSWORD_RESET',
};
