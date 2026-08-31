// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_challenge_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegisterChallengeResponseCWProxy {
  RegisterChallengeResponse challengeId(String? challengeId);

  RegisterChallengeResponse maskedDestination(String? maskedDestination);

  RegisterChallengeResponse purpose(
    RegisterChallengeResponsePurposeEnum? purpose,
  );

  RegisterChallengeResponse expiresAt(DateTime? expiresAt);

  RegisterChallengeResponse resendAvailableAt(DateTime? resendAvailableAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterChallengeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterChallengeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterChallengeResponse call({
    String? challengeId,
    String? maskedDestination,
    RegisterChallengeResponsePurposeEnum? purpose,
    DateTime? expiresAt,
    DateTime? resendAvailableAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRegisterChallengeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRegisterChallengeResponse.copyWith.fieldName(...)`
class _$RegisterChallengeResponseCWProxyImpl
    implements _$RegisterChallengeResponseCWProxy {
  const _$RegisterChallengeResponseCWProxyImpl(this._value);

  final RegisterChallengeResponse _value;

  @override
  RegisterChallengeResponse challengeId(String? challengeId) =>
      this(challengeId: challengeId);

  @override
  RegisterChallengeResponse maskedDestination(String? maskedDestination) =>
      this(maskedDestination: maskedDestination);

  @override
  RegisterChallengeResponse purpose(
    RegisterChallengeResponsePurposeEnum? purpose,
  ) => this(purpose: purpose);

  @override
  RegisterChallengeResponse expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  RegisterChallengeResponse resendAvailableAt(DateTime? resendAvailableAt) =>
      this(resendAvailableAt: resendAvailableAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterChallengeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterChallengeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterChallengeResponse call({
    Object? challengeId = const $CopyWithPlaceholder(),
    Object? maskedDestination = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? resendAvailableAt = const $CopyWithPlaceholder(),
  }) {
    return RegisterChallengeResponse(
      challengeId: challengeId == const $CopyWithPlaceholder()
          ? _value.challengeId
          // ignore: cast_nullable_to_non_nullable
          : challengeId as String?,
      maskedDestination: maskedDestination == const $CopyWithPlaceholder()
          ? _value.maskedDestination
          // ignore: cast_nullable_to_non_nullable
          : maskedDestination as String?,
      purpose: purpose == const $CopyWithPlaceholder()
          ? _value.purpose
          // ignore: cast_nullable_to_non_nullable
          : purpose as RegisterChallengeResponsePurposeEnum?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      resendAvailableAt: resendAvailableAt == const $CopyWithPlaceholder()
          ? _value.resendAvailableAt
          // ignore: cast_nullable_to_non_nullable
          : resendAvailableAt as DateTime?,
    );
  }
}

extension $RegisterChallengeResponseCopyWith on RegisterChallengeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfRegisterChallengeResponse.copyWith(...)` or like so:`instanceOfRegisterChallengeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegisterChallengeResponseCWProxy get copyWith =>
      _$RegisterChallengeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterChallengeResponse _$RegisterChallengeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RegisterChallengeResponse', json, ($checkedConvert) {
  final val = RegisterChallengeResponse(
    challengeId: $checkedConvert('challengeId', (v) => v as String?),
    maskedDestination: $checkedConvert(
      'maskedDestination',
      (v) => v as String?,
    ),
    purpose: $checkedConvert(
      'purpose',
      (v) =>
          $enumDecodeNullable(_$RegisterChallengeResponsePurposeEnumEnumMap, v),
    ),
    expiresAt: $checkedConvert(
      'expiresAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    resendAvailableAt: $checkedConvert(
      'resendAvailableAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$RegisterChallengeResponseToJson(
  RegisterChallengeResponse instance,
) => <String, dynamic>{
  'challengeId': ?instance.challengeId,
  'maskedDestination': ?instance.maskedDestination,
  'purpose': ?_$RegisterChallengeResponsePurposeEnumEnumMap[instance.purpose],
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'resendAvailableAt': ?instance.resendAvailableAt?.toIso8601String(),
};

const _$RegisterChallengeResponsePurposeEnumEnumMap = {
  RegisterChallengeResponsePurposeEnum.REGISTER: 'REGISTER',
  RegisterChallengeResponsePurposeEnum.PASSWORD_RESET: 'PASSWORD_RESET',
};
