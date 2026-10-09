# viegym_api.api.WorkoutScheduleControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelSchedule**](WorkoutScheduleControllerApi.md#cancelschedule) | **DELETE** /api/v1/workout-schedules/{id} |
[**createSchedule**](WorkoutScheduleControllerApi.md#createschedule) | **POST** /api/v1/workout-schedules |
[**getSchedule**](WorkoutScheduleControllerApi.md#getschedule) | **GET** /api/v1/workout-schedules/{id} |
[**listSchedules**](WorkoutScheduleControllerApi.md#listschedules) | **GET** /api/v1/workout-schedules |
[**updateSchedule**](WorkoutScheduleControllerApi.md#updateschedule) | **PUT** /api/v1/workout-schedules/{id} |


# **cancelSchedule**
> ApiResponseVoid cancelSchedule(id, cancelReason)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutScheduleControllerApi();
final int id = 789; // int |
final String cancelReason = cancelReason_example; // String |

try {
    final response = api.cancelSchedule(id, cancelReason);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutScheduleControllerApi->cancelSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **cancelReason** | **String**|  | [optional]

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSchedule**
> ApiResponseWorkoutScheduleResponse createSchedule(workoutScheduleRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutScheduleControllerApi();
final WorkoutScheduleRequest workoutScheduleRequest = ; // WorkoutScheduleRequest |

try {
    final response = api.createSchedule(workoutScheduleRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutScheduleControllerApi->createSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workoutScheduleRequest** | [**WorkoutScheduleRequest**](WorkoutScheduleRequest.md)|  |

### Return type

[**ApiResponseWorkoutScheduleResponse**](ApiResponseWorkoutScheduleResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSchedule**
> ApiResponseWorkoutScheduleResponse getSchedule(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutScheduleControllerApi();
final int id = 789; // int |

try {
    final response = api.getSchedule(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutScheduleControllerApi->getSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseWorkoutScheduleResponse**](ApiResponseWorkoutScheduleResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSchedules**
> ApiResponsePageResponseWorkoutScheduleResponse listSchedules(from, to, status, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutScheduleControllerApi();
final DateTime from = 2013-10-20; // DateTime |
final DateTime to = 2013-10-20; // DateTime |
final String status = status_example; // String |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.listSchedules(from, to, status, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutScheduleControllerApi->listSchedules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **DateTime**|  | [optional]
 **to** | **DateTime**|  | [optional]
 **status** | **String**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponseWorkoutScheduleResponse**](ApiResponsePageResponseWorkoutScheduleResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSchedule**
> ApiResponseWorkoutScheduleResponse updateSchedule(id, workoutScheduleRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutScheduleControllerApi();
final int id = 789; // int |
final WorkoutScheduleRequest workoutScheduleRequest = ; // WorkoutScheduleRequest |

try {
    final response = api.updateSchedule(id, workoutScheduleRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutScheduleControllerApi->updateSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **workoutScheduleRequest** | [**WorkoutScheduleRequest**](WorkoutScheduleRequest.md)|  |

### Return type

[**ApiResponseWorkoutScheduleResponse**](ApiResponseWorkoutScheduleResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
