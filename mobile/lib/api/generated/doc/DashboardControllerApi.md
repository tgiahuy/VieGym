# viegym_api.api.DashboardControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDashboard**](DashboardControllerApi.md#getdashboard) | **GET** /api/v1/dashboard |


# **getDashboard**
> ApiResponseDashboardResponse getDashboard(date)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getDashboardControllerApi();
final DateTime date = 2013-10-20; // DateTime |

try {
    final response = api.getDashboard(date);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DashboardControllerApi->getDashboard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **DateTime**|  | [optional]

### Return type

[**ApiResponseDashboardResponse**](ApiResponseDashboardResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
