# viegym_api.api.UserProfileControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**callGet**](UserProfileControllerApi.md#callget) | **GET** /api/v1/users/me |
[**update**](UserProfileControllerApi.md#update) | **PUT** /api/v1/users/me |


# **callGet**
> ApiResponseUserResponse callGet()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getUserProfileControllerApi();

try {
    final response = api.callGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserProfileControllerApi->callGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseUserResponse**](ApiResponseUserResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **update**
> ApiResponseUserResponse update(updateUserRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getUserProfileControllerApi();
final UpdateUserRequest updateUserRequest = ; // UpdateUserRequest |

try {
    final response = api.update(updateUserRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UserProfileControllerApi->update: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateUserRequest** | [**UpdateUserRequest**](UpdateUserRequest.md)|  |

### Return type

[**ApiResponseUserResponse**](ApiResponseUserResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
