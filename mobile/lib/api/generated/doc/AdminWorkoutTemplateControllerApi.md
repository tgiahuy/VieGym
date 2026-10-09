# viegym_api.api.AdminWorkoutTemplateControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**archive**](AdminWorkoutTemplateControllerApi.md#archive) | **DELETE** /api/v1/admin/workout-program-templates/{id} | 
[**create2**](AdminWorkoutTemplateControllerApi.md#create2) | **POST** /api/v1/admin/workout-program-templates | 
[**list**](AdminWorkoutTemplateControllerApi.md#list) | **GET** /api/v1/admin/workout-program-templates | 
[**update2**](AdminWorkoutTemplateControllerApi.md#update2) | **PUT** /api/v1/admin/workout-program-templates/{id} | 


# **archive**
> ApiResponseVoid archive(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAdminWorkoutTemplateControllerApi();
final int id = 789; // int | 

try {
    final response = api.archive(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminWorkoutTemplateControllerApi->archive: $e\n');
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

# **create2**
> ApiResponseWorkoutTemplateResponse create2(workoutTemplateRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAdminWorkoutTemplateControllerApi();
final WorkoutTemplateRequest workoutTemplateRequest = ; // WorkoutTemplateRequest | 

try {
    final response = api.create2(workoutTemplateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminWorkoutTemplateControllerApi->create2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **workoutTemplateRequest** | [**WorkoutTemplateRequest**](WorkoutTemplateRequest.md)|  | 

### Return type

[**ApiResponseWorkoutTemplateResponse**](ApiResponseWorkoutTemplateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **list**
> ApiResponseListWorkoutTemplateResponse list()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAdminWorkoutTemplateControllerApi();

try {
    final response = api.list();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminWorkoutTemplateControllerApi->list: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseListWorkoutTemplateResponse**](ApiResponseListWorkoutTemplateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **update2**
> ApiResponseWorkoutTemplateResponse update2(id, workoutTemplateRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getAdminWorkoutTemplateControllerApi();
final int id = 789; // int | 
final WorkoutTemplateRequest workoutTemplateRequest = ; // WorkoutTemplateRequest | 

try {
    final response = api.update2(id, workoutTemplateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminWorkoutTemplateControllerApi->update2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **workoutTemplateRequest** | [**WorkoutTemplateRequest**](WorkoutTemplateRequest.md)|  | 

### Return type

[**ApiResponseWorkoutTemplateResponse**](ApiResponseWorkoutTemplateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

