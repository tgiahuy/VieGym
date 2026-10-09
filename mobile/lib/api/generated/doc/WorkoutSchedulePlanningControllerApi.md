# viegym_api.api.WorkoutSchedulePlanningControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apply**](WorkoutSchedulePlanningControllerApi.md#apply) | **POST** /api/v1/workout-schedule-proposals/{id}/apply | 
[**create1**](WorkoutSchedulePlanningControllerApi.md#create1) | **POST** /api/v1/workout-schedule-proposals | 
[**get3**](WorkoutSchedulePlanningControllerApi.md#get3) | **GET** /api/v1/workout-schedule-proposals/{id} | 


# **apply**
> ApiResponseApplyScheduleProposalResponse apply(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSchedulePlanningControllerApi();
final int id = 789; // int | 

try {
    final response = api.apply(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSchedulePlanningControllerApi->apply: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseApplyScheduleProposalResponse**](ApiResponseApplyScheduleProposalResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **create1**
> ApiResponseScheduleProposalResponse create1(createScheduleProposalRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSchedulePlanningControllerApi();
final CreateScheduleProposalRequest createScheduleProposalRequest = ; // CreateScheduleProposalRequest | 

try {
    final response = api.create1(createScheduleProposalRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSchedulePlanningControllerApi->create1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createScheduleProposalRequest** | [**CreateScheduleProposalRequest**](CreateScheduleProposalRequest.md)|  | 

### Return type

[**ApiResponseScheduleProposalResponse**](ApiResponseScheduleProposalResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **get3**
> ApiResponseScheduleProposalResponse get3(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWorkoutSchedulePlanningControllerApi();
final int id = 789; // int | 

try {
    final response = api.get3(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WorkoutSchedulePlanningControllerApi->get3: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ApiResponseScheduleProposalResponse**](ApiResponseScheduleProposalResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

