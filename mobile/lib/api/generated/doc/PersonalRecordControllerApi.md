# viegym_api.api.PersonalRecordControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listPersonalRecords**](PersonalRecordControllerApi.md#listpersonalrecords) | **GET** /api/v1/personal-records |


# **listPersonalRecords**
> ApiResponsePageResponsePersonalRecordDto listPersonalRecords(exerciseId, type, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getPersonalRecordControllerApi();
final int exerciseId = 789; // int |
final String type = type_example; // String |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.listPersonalRecords(exerciseId, type, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PersonalRecordControllerApi->listPersonalRecords: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exerciseId** | **int**|  | [optional]
 **type** | **String**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponsePersonalRecordDto**](ApiResponsePageResponsePersonalRecordDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
