# viegym_api.api.HealthProfileControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**create**](HealthProfileControllerApi.md#create) | **POST** /api/v1/health/profile |
[**get2**](HealthProfileControllerApi.md#get2) | **GET** /api/v1/health/profile |
[**update1**](HealthProfileControllerApi.md#update1) | **PUT** /api/v1/health/profile |


# **create**
> ApiResponseHealthProfileResponse create(createHealthProfileRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getHealthProfileControllerApi();
final CreateHealthProfileRequest createHealthProfileRequest = ; // CreateHealthProfileRequest |

try {
    final response = api.create(createHealthProfileRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling HealthProfileControllerApi->create: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createHealthProfileRequest** | [**CreateHealthProfileRequest**](CreateHealthProfileRequest.md)|  |

### Return type

[**ApiResponseHealthProfileResponse**](ApiResponseHealthProfileResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **get2**
> ApiResponseHealthProfileResponse get2()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getHealthProfileControllerApi();

try {
    final response = api.get2();
    print(response);
} catch on DioException (e) {
    print('Exception when calling HealthProfileControllerApi->get2: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseHealthProfileResponse**](ApiResponseHealthProfileResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **update1**
> ApiResponseHealthProfileResponse update1(updateHealthProfileRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getHealthProfileControllerApi();
final UpdateHealthProfileRequest updateHealthProfileRequest = ; // UpdateHealthProfileRequest |

try {
    final response = api.update1(updateHealthProfileRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling HealthProfileControllerApi->update1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateHealthProfileRequest** | [**UpdateHealthProfileRequest**](UpdateHealthProfileRequest.md)|  |

### Return type

[**ApiResponseHealthProfileResponse**](ApiResponseHealthProfileResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
