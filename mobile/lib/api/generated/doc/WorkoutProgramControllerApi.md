# viegym_api.api.WorkoutProgramControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**archiveProgram**](WorkoutProgramControllerApi.md#archiveprogram) | **DELETE** /api/v1/workout-programs/{id} |
[**createProgram**](WorkoutProgramControllerApi.md#createprogram) | **POST** /api/v1/workout-programs |
[**getProgram**](WorkoutProgramControllerApi.md#getprogram) | **GET** /api/v1/workout-programs/{id} |
[**listPrograms**](WorkoutProgramControllerApi.md#listprograms) | **GET** /api/v1/workout-programs |
[**updateProgram**](WorkoutProgramControllerApi.md#updateprogram) | **PUT** /api/v1/workout-programs/{id} |


# **archiveProgram**
> ApiResponseVoid archiveProgram(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutProgramControllerApi();
final int id = 789; // int |

try {
    final response = api.archiveProgram(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutProgramControllerApi->archiveProgram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createProgram**
> ApiResponseWorkoutProgramResponse createProgram(workoutProgramRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutProgramControllerApi();
final WorkoutProgramRequest workoutProgramRequest = ; // WorkoutProgramRequest |

try {
    final response = api.createProgram(workoutProgramRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutProgramControllerApi->createProgram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workoutProgramRequest** | [**WorkoutProgramRequest**](WorkoutProgramRequest.md)|  |

### Return type

[**ApiResponseWorkoutProgramResponse**](ApiResponseWorkoutProgramResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProgram**
> ApiResponseWorkoutProgramResponse getProgram(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutProgramControllerApi();
final int id = 789; // int |

try {
    final response = api.getProgram(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutProgramControllerApi->getProgram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseWorkoutProgramResponse**](ApiResponseWorkoutProgramResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPrograms**
> ApiResponsePageResponseWorkoutProgramSummaryResponse listPrograms(status, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutProgramControllerApi();
final String status = status_example; // String |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.listPrograms(status, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutProgramControllerApi->listPrograms: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | **String**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponseWorkoutProgramSummaryResponse**](ApiResponsePageResponseWorkoutProgramSummaryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateProgram**
> ApiResponseWorkoutProgramResponse updateProgram(id, workoutProgramRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutProgramControllerApi();
final int id = 789; // int |
final WorkoutProgramRequest workoutProgramRequest = ; // WorkoutProgramRequest |

try {
    final response = api.updateProgram(id, workoutProgramRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutProgramControllerApi->updateProgram: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **workoutProgramRequest** | [**WorkoutProgramRequest**](WorkoutProgramRequest.md)|  |

### Return type

[**ApiResponseWorkoutProgramResponse**](ApiResponseWorkoutProgramResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
