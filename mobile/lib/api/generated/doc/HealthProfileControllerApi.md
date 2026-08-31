# viegym_api.api.HealthProfileControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**create**](HealthProfileControllerApi.md#create) | **POST** /api/v1/health/profile |


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
