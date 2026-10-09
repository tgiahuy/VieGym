# viegym_api.api.WorkoutSessionControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**discardSession**](WorkoutSessionControllerApi.md#discardsession) | **POST** /api/v1/workout-sessions/{id}/discard |
[**finishSession**](WorkoutSessionControllerApi.md#finishsession) | **POST** /api/v1/workout-sessions/{id}/finish |
[**pauseSession**](WorkoutSessionControllerApi.md#pausesession) | **POST** /api/v1/workout-sessions/{id}/pause |
[**resumeSession**](WorkoutSessionControllerApi.md#resumesession) | **POST** /api/v1/workout-sessions/{id}/resume |
[**startSession**](WorkoutSessionControllerApi.md#startsession) | **POST** /api/v1/workout-sessions/{scheduleId}/start |


# **discardSession**
> ApiResponseVoid discardSession(id, discardSessionRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSessionControllerApi();
final int id = 789; // int |
final DiscardSessionRequest discardSessionRequest = ; // DiscardSessionRequest |

try {
    final response = api.discardSession(id, discardSessionRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSessionControllerApi->discardSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **discardSessionRequest** | [**DiscardSessionRequest**](DiscardSessionRequest.md)|  | [optional]

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **finishSession**
> ApiResponseFinishSessionResponse finishSession(id, finishSessionRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSessionControllerApi();
final int id = 789; // int |
final FinishSessionRequest finishSessionRequest = ; // FinishSessionRequest |

try {
    final response = api.finishSession(id, finishSessionRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSessionControllerApi->finishSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **finishSessionRequest** | [**FinishSessionRequest**](FinishSessionRequest.md)|  |

### Return type

[**ApiResponseFinishSessionResponse**](ApiResponseFinishSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pauseSession**
> ApiResponsePauseSessionResponse pauseSession(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSessionControllerApi();
final int id = 789; // int |

try {
    final response = api.pauseSession(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSessionControllerApi->pauseSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponsePauseSessionResponse**](ApiResponsePauseSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resumeSession**
> ApiResponseResumeSessionResponse resumeSession(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSessionControllerApi();
final int id = 789; // int |

try {
    final response = api.resumeSession(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSessionControllerApi->resumeSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseResumeSessionResponse**](ApiResponseResumeSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startSession**
> ApiResponseStartSessionResponse startSession(scheduleId)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSessionControllerApi();
final int scheduleId = 789; // int |

try {
    final response = api.startSession(scheduleId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSessionControllerApi->startSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **scheduleId** | **int**|  |

### Return type

[**ApiResponseStartSessionResponse**](ApiResponseStartSessionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
