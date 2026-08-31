import 'package:viegym_api/src/model/api_response_equipment_preference_response.dart';
import 'package:viegym_api/src/model/api_response_health_profile_response.dart';
import 'package:viegym_api/src/model/api_response_preference_response.dart';
import 'package:viegym_api/src/model/api_response_register_challenge_response.dart';
import 'package:viegym_api/src/model/api_response_session_response.dart';
import 'package:viegym_api/src/model/api_response_user_response.dart';
import 'package:viegym_api/src/model/api_response_void.dart';
import 'package:viegym_api/src/model/avatar_response.dart';
import 'package:viegym_api/src/model/change_password_request.dart';
import 'package:viegym_api/src/model/create_health_profile_request.dart';
import 'package:viegym_api/src/model/equipment_item.dart';
import 'package:viegym_api/src/model/equipment_preference_request.dart';
import 'package:viegym_api/src/model/equipment_preference_response.dart';
import 'package:viegym_api/src/model/forgot_password_request.dart';
import 'package:viegym_api/src/model/google_login_request.dart';
import 'package:viegym_api/src/model/health_profile_response.dart';
import 'package:viegym_api/src/model/login_request.dart';
import 'package:viegym_api/src/model/logout_request.dart';
import 'package:viegym_api/src/model/metrics.dart';
import 'package:viegym_api/src/model/nutrition_target.dart';
import 'package:viegym_api/src/model/onboarding_response.dart';
import 'package:viegym_api/src/model/otp_resend_request.dart';
import 'package:viegym_api/src/model/otp_verify_request.dart';
import 'package:viegym_api/src/model/preference_request.dart';
import 'package:viegym_api/src/model/preference_response.dart';
import 'package:viegym_api/src/model/profile.dart';
import 'package:viegym_api/src/model/refresh_request.dart';
import 'package:viegym_api/src/model/register_challenge_response.dart';
import 'package:viegym_api/src/model/register_request.dart';
import 'package:viegym_api/src/model/reset_password_request.dart';
import 'package:viegym_api/src/model/session_response.dart';
import 'package:viegym_api/src/model/update_user_request.dart';
import 'package:viegym_api/src/model/user_response.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'ApiResponseEquipmentPreferenceResponse':
      return ApiResponseEquipmentPreferenceResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseHealthProfileResponse':
      return ApiResponseHealthProfileResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePreferenceResponse':
      return ApiResponsePreferenceResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseRegisterChallengeResponse':
      return ApiResponseRegisterChallengeResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseSessionResponse':
      return ApiResponseSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseUserResponse':
      return ApiResponseUserResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseVoid':
      return ApiResponseVoid.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AvatarResponse':
      return AvatarResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangePasswordRequest':
      return ChangePasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateHealthProfileRequest':
      return CreateHealthProfileRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentItem':
      return EquipmentItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentPreferenceRequest':
      return EquipmentPreferenceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentPreferenceResponse':
      return EquipmentPreferenceResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordRequest':
      return ForgotPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GoogleLoginRequest':
      return GoogleLoginRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthProfileResponse':
      return HealthProfileResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginRequest':
      return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LogoutRequest':
      return LogoutRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Metrics':
      return Metrics.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'NutritionTarget':
      return NutritionTarget.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OnboardingResponse':
      return OnboardingResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpResendRequest':
      return OtpResendRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpVerifyRequest':
      return OtpVerifyRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PreferenceRequest':
      return PreferenceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PreferenceResponse':
      return PreferenceResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Profile':
      return Profile.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RefreshRequest':
      return RefreshRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterChallengeResponse':
      return RegisterChallengeResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterRequest':
      return RegisterRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResetPasswordRequest':
      return ResetPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SessionResponse':
      return SessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateUserRequest':
      return UpdateUserRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserResponse':
      return UserResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
