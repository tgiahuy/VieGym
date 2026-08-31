# viegym_api.api.AuthControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**changePassword**](AuthControllerApi.md#changepassword) | **POST** /api/v1/auth/password/change |
[**forgotPassword**](AuthControllerApi.md#forgotpassword) | **POST** /api/v1/auth/password/forgot |
[**google**](AuthControllerApi.md#google) | **POST** /api/v1/auth/google |
[**login**](AuthControllerApi.md#login) | **POST** /api/v1/auth/login |
[**logout**](AuthControllerApi.md#logout) | **POST** /api/v1/auth/logout |
[**refresh**](AuthControllerApi.md#refresh) | **POST** /api/v1/auth/refresh |
[**register**](AuthControllerApi.md#register) | **POST** /api/v1/auth/register |
[**resendOtp**](AuthControllerApi.md#resendotp) | **POST** /api/v1/auth/otp/resend |
[**resetPassword**](AuthControllerApi.md#resetpassword) | **POST** /api/v1/auth/password/reset |
[**verifyOtp**](AuthControllerApi.md#verifyotp) | **POST** /api/v1/auth/otp/verify |


# **changePassword**
> ApiResponseVoid changePassword(changePasswordRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final ChangePasswordRequest changePasswordRequest = ; // ChangePasswordRequest |

try {
    final response = api.changePassword(changePasswordRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->changePassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordRequest** | [**ChangePasswordRequest**](ChangePasswordRequest.md)|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **forgotPassword**
> ApiResponseRegisterChallengeResponse forgotPassword(forgotPasswordRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final ForgotPasswordRequest forgotPasswordRequest = ; // ForgotPasswordRequest |

try {
    final response = api.forgotPassword(forgotPasswordRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->forgotPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordRequest** | [**ForgotPasswordRequest**](ForgotPasswordRequest.md)|  |

### Return type

[**ApiResponseRegisterChallengeResponse**](ApiResponseRegisterChallengeResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **google**
> ApiResponseSessionResponse google(googleLoginRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final GoogleLoginRequest googleLoginRequest = ; // GoogleLoginRequest |

try {
    final response = api.google(googleLoginRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->google: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **googleLoginRequest** | [**GoogleLoginRequest**](GoogleLoginRequest.md)|  |

### Return type

[**ApiResponseSessionResponse**](ApiResponseSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> ApiResponseSessionResponse login(loginRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final LoginRequest loginRequest = ; // LoginRequest |

try {
    final response = api.login(loginRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  |

### Return type

[**ApiResponseSessionResponse**](ApiResponseSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> ApiResponseVoid logout(logoutRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final LogoutRequest logoutRequest = ; // LogoutRequest |

try {
    final response = api.logout(logoutRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logoutRequest** | [**LogoutRequest**](LogoutRequest.md)|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refresh**
> ApiResponseSessionResponse refresh(refreshRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final RefreshRequest refreshRequest = ; // RefreshRequest |

try {
    final response = api.refresh(refreshRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->refresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  |

### Return type

[**ApiResponseSessionResponse**](ApiResponseSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **register**
> ApiResponseRegisterChallengeResponse register(registerRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final RegisterRequest registerRequest = ; // RegisterRequest |

try {
    final response = api.register(registerRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->register: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  |

### Return type

[**ApiResponseRegisterChallengeResponse**](ApiResponseRegisterChallengeResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendOtp**
> ApiResponseRegisterChallengeResponse resendOtp(otpResendRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final OtpResendRequest otpResendRequest = ; // OtpResendRequest |

try {
    final response = api.resendOtp(otpResendRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->resendOtp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **otpResendRequest** | [**OtpResendRequest**](OtpResendRequest.md)|  |

### Return type

[**ApiResponseRegisterChallengeResponse**](ApiResponseRegisterChallengeResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPassword**
> ApiResponseVoid resetPassword(resetPasswordRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final ResetPasswordRequest resetPasswordRequest = ; // ResetPasswordRequest |

try {
    final response = api.resetPassword(resetPasswordRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->resetPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyOtp**
> ApiResponseSessionResponse verifyOtp(otpVerifyRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAuthControllerApi();
final OtpVerifyRequest otpVerifyRequest = ; // OtpVerifyRequest |

try {
    final response = api.verifyOtp(otpVerifyRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthControllerApi->verifyOtp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **otpVerifyRequest** | [**OtpVerifyRequest**](OtpVerifyRequest.md)|  |

### Return type

[**ApiResponseSessionResponse**](ApiResponseSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
