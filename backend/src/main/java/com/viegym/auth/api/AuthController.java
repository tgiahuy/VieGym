package com.viegym.auth.api;

import com.viegym.auth.application.FacebookLoginService;
import com.viegym.auth.application.GoogleLoginService;
import com.viegym.auth.application.LoginService;
import com.viegym.auth.application.OtpResendService;
import com.viegym.auth.application.OtpVerificationService;
import com.viegym.auth.application.PasswordService;
import com.viegym.auth.application.RegistrationService;
import com.viegym.auth.application.SessionService;
import com.viegym.common.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private static final String REGISTER_SUCCESS_MESSAGE =
            "Verification instructions have been sent if the address is eligible";
    private static final String OTP_VERIFY_SUCCESS_MESSAGE = "Account verified successfully";
    private static final String OTP_RESEND_SUCCESS_MESSAGE =
            "Verification instructions have been sent if the address is eligible";

    private final RegistrationService registrationService;
    private final OtpVerificationService otpVerificationService;
    private final OtpResendService otpResendService;
    private final LoginService loginService;
    private final SessionService sessionService;
    private final PasswordService passwordService;
    private final GoogleLoginService googleLoginService;
    private final FacebookLoginService facebookLoginService;

    public AuthController(
            RegistrationService registrationService,
            OtpVerificationService otpVerificationService,
            OtpResendService otpResendService,
            LoginService loginService,
            SessionService sessionService,
            PasswordService passwordService,
            GoogleLoginService googleLoginService,
            FacebookLoginService facebookLoginService) {
        this.registrationService = registrationService;
        this.otpVerificationService = otpVerificationService;
        this.otpResendService = otpResendService;
        this.loginService = loginService;
        this.sessionService = sessionService;
        this.passwordService = passwordService;
        this.googleLoginService = googleLoginService;
        this.facebookLoginService = facebookLoginService;
    }

    @PostMapping("/register")
    ResponseEntity<ApiResponse<RegisterChallengeResponse>> register(
            @RequestBody RegisterRequest request) {
        RegisterChallengeResponse response = registrationService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(REGISTER_SUCCESS_MESSAGE, response));
    }

    @PostMapping("/otp/verify")
    ResponseEntity<ApiResponse<SessionResponse>> verifyOtp(@RequestBody OtpVerifyRequest request) {
        SessionResponse response = otpVerificationService.verify(request);
        return ResponseEntity.ok(ApiResponse.success(OTP_VERIFY_SUCCESS_MESSAGE, response));
    }

    @PostMapping("/otp/resend")
    ResponseEntity<ApiResponse<RegisterChallengeResponse>> resendOtp(
            @RequestBody OtpResendRequest request) {
        RegisterChallengeResponse response = otpResendService.resend(request);
        return ResponseEntity.ok(ApiResponse.success(OTP_RESEND_SUCCESS_MESSAGE, response));
    }

    @PostMapping("/login")
    ResponseEntity<ApiResponse<SessionResponse>> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success(loginService.login(request)));
    }

    @PostMapping("/google")
    ResponseEntity<ApiResponse<SessionResponse>> google(@RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success(googleLoginService.login(request)));
    }

    @PostMapping("/facebook")
    ResponseEntity<ApiResponse<SessionResponse>> facebook(
            @RequestBody FacebookLoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success(facebookLoginService.login(request)));
    }

    @PostMapping("/refresh")
    ResponseEntity<ApiResponse<SessionResponse>> refresh(@RequestBody RefreshRequest request) {
        return ResponseEntity.ok(ApiResponse.success(sessionService.refresh(request)));
    }

    @PostMapping("/logout")
    ResponseEntity<ApiResponse<Void>> logout(
            @RequestBody LogoutRequest request, @AuthenticationPrincipal Jwt jwt) {
        sessionService.logout(
                request == null ? null : request.refreshToken(), Long.valueOf(jwt.getSubject()));
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/password/forgot")
    ResponseEntity<ApiResponse<RegisterChallengeResponse>> forgotPassword(
            @RequestBody ForgotPasswordRequest request) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Password reset instructions have been sent if the address is eligible",
                        passwordService.forgot(request)));
    }

    @PostMapping("/password/reset")
    ResponseEntity<ApiResponse<Void>> resetPassword(@RequestBody ResetPasswordRequest request) {
        passwordService.reset(request);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @PostMapping("/password/change")
    ResponseEntity<ApiResponse<Void>> changePassword(
            @RequestBody ChangePasswordRequest request, @AuthenticationPrincipal Jwt jwt) {
        passwordService.change(Long.valueOf(jwt.getSubject()), request);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
