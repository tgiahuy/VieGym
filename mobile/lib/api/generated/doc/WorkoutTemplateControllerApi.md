# viegym_api.api.WorkoutTemplateControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**get4**](WorkoutTemplateControllerApi.md#get4) | **GET** /api/v1/workout-program-templates/{id} | 
[**list1**](WorkoutTemplateControllerApi.md#list1) | **GET** /api/v1/workout-program-templates | 


# **get4**
> ApiResponseWorkoutTemplateResponse get4(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutTemplateControllerApi();
final int id = 789; // int | 

try {
    final response = api.get4(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutTemplateControllerApi->get4: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseWorkoutTemplateResponse**](ApiResponseWorkoutTemplateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **list1**
> ApiResponseListWorkoutTemplateResponse list1()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutTemplateControllerApi();

try {
    final response = api.list1();
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutTemplateControllerApi->list1: $e\n');
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

