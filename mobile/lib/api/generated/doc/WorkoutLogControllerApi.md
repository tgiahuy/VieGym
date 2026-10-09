# viegym_api.api.WorkoutLogControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getWorkoutLogDetail**](WorkoutLogControllerApi.md#getworkoutlogdetail) | **GET** /api/v1/workout-logs/{id} |
[**listWorkoutLogs**](WorkoutLogControllerApi.md#listworkoutlogs) | **GET** /api/v1/workout-logs |


# **getWorkoutLogDetail**
> ApiResponseWorkoutLogDetailDto getWorkoutLogDetail(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutLogControllerApi();
final int id = 789; // int |

try {
    final response = api.getWorkoutLogDetail(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutLogControllerApi->getWorkoutLogDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseWorkoutLogDetailDto**](ApiResponseWorkoutLogDetailDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listWorkoutLogs**
> ApiResponsePageResponseWorkoutLogSummaryDto listWorkoutLogs(from, to, exerciseId, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutLogControllerApi();
final DateTime from = 2013-10-20; // DateTime |
final DateTime to = 2013-10-20; // DateTime |
final int exerciseId = 789; // int |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.listWorkoutLogs(from, to, exerciseId, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutLogControllerApi->listWorkoutLogs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **DateTime**|  | [optional]
 **to** | **DateTime**|  | [optional]
 **exerciseId** | **int**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponseWorkoutLogSummaryDto**](ApiResponsePageResponseWorkoutLogSummaryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
