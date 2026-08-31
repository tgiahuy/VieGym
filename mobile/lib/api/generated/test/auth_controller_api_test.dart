import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for AuthControllerApi
void main() {
  final instance = ViegymApi().getAuthControllerApi();

  group(AuthControllerApi, () {
    //Future<ApiResponseVoid> changePassword(ChangePasswordRequest changePasswordRequest) async
    test('test changePassword', () async {
      // TODO
    });

    //Future<ApiResponseRegisterChallengeResponse> forgotPassword(ForgotPasswordRequest forgotPasswordRequest) async
    test('test forgotPassword', () async {
      // TODO
    });

    //Future<ApiResponseSessionResponse> google(GoogleLoginRequest googleLoginRequest) async
    test('test google', () async {
      // TODO
    });

    //Future<ApiResponseSessionResponse> login(LoginRequest loginRequest) async
    test('test login', () async {
      // TODO
    });

    //Future<ApiResponseVoid> logout(LogoutRequest logoutRequest) async
    test('test logout', () async {
      // TODO
    });

    //Future<ApiResponseSessionResponse> refresh(RefreshRequest refreshRequest) async
    test('test refresh', () async {
      // TODO
    });

    //Future<ApiResponseRegisterChallengeResponse> register(RegisterRequest registerRequest) async
    test('test register', () async {
      // TODO
    });

    //Future<ApiResponseRegisterChallengeResponse> resendOtp(OtpResendRequest otpResendRequest) async
    test('test resendOtp', () async {
      // TODO
    });

    //Future<ApiResponseVoid> resetPassword(ResetPasswordRequest resetPasswordRequest) async
    test('test resetPassword', () async {
      // TODO
    });

    //Future<ApiResponseSessionResponse> verifyOtp(OtpVerifyRequest otpVerifyRequest) async
    test('test verifyOtp', () async {
      // TODO
    });
  });
}
