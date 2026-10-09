# viegym_api.api.ExerciseCatalogControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addFavorite1**](ExerciseCatalogControllerApi.md#addfavorite1) | **PUT** /api/v1/favorite-exercises/{exerciseId} |
[**getExerciseAlternatives**](ExerciseCatalogControllerApi.md#getexercisealternatives) | **GET** /api/v1/exercises/{id}/alternatives |
[**getExerciseDetail**](ExerciseCatalogControllerApi.md#getexercisedetail) | **GET** /api/v1/exercises/{id} |
[**listEquipment**](ExerciseCatalogControllerApi.md#listequipment) | **GET** /api/v1/equipment |
[**listFavoriteExercises**](ExerciseCatalogControllerApi.md#listfavoriteexercises) | **GET** /api/v1/favorite-exercises |
[**listMuscleGroups**](ExerciseCatalogControllerApi.md#listmusclegroups) | **GET** /api/v1/muscle-groups |
[**removeFavorite1**](ExerciseCatalogControllerApi.md#removefavorite1) | **DELETE** /api/v1/favorite-exercises/{exerciseId} |
[**searchExercises**](ExerciseCatalogControllerApi.md#searchexercises) | **GET** /api/v1/exercises |


# **addFavorite1**
> ApiResponseVoid addFavorite1(exerciseId)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();
final int exerciseId = 789; // int |

try {
    final response = api.addFavorite1(exerciseId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->addFavorite1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exerciseId** | **int**|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExerciseAlternatives**
> ApiResponseListExerciseSummaryDto getExerciseAlternatives(id, limit)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();
final int id = 789; // int |
final int limit = 56; // int |

try {
    final response = api.getExerciseAlternatives(id, limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->getExerciseAlternatives: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **limit** | **int**|  | [optional] [default to 5]

### Return type

[**ApiResponseListExerciseSummaryDto**](ApiResponseListExerciseSummaryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExerciseDetail**
> ApiResponseExerciseDetailDto getExerciseDetail(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();
final int id = 789; // int |

try {
    final response = api.getExerciseDetail(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->getExerciseDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseExerciseDetailDto**](ApiResponseExerciseDetailDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEquipment**
> ApiResponseListEquipmentDto listEquipment()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();

try {
    final response = api.listEquipment();
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->listEquipment: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseListEquipmentDto**](ApiResponseListEquipmentDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFavoriteExercises**
> ApiResponsePageResponseExerciseSummaryDto listFavoriteExercises(q, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();
final String q = q_example; // String |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.listFavoriteExercises(q, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->listFavoriteExercises: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponseExerciseSummaryDto**](ApiResponsePageResponseExerciseSummaryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMuscleGroups**
> ApiResponseListMuscleGroupDto listMuscleGroups()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();

try {
    final response = api.listMuscleGroups();
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->listMuscleGroups: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseListMuscleGroupDto**](ApiResponseListMuscleGroupDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeFavorite1**
> ApiResponseVoid removeFavorite1(exerciseId)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();
final int exerciseId = 789; // int |

try {
    final response = api.removeFavorite1(exerciseId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->removeFavorite1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **exerciseId** | **int**|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchExercises**
> ApiResponsePageResponseExerciseSummaryDto searchExercises(q, muscleGroupId, equipmentId, difficulty, compatibleWithMyEquipment, page, size, sort)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getExerciseCatalogControllerApi();
final String q = q_example; // String |
final int muscleGroupId = 789; // int |
final int equipmentId = 789; // int |
final String difficulty = difficulty_example; // String |
final bool compatibleWithMyEquipment = true; // bool |
final int page = 56; // int |
final int size = 56; // int |
final String sort = sort_example; // String |

try {
    final response = api.searchExercises(q, muscleGroupId, equipmentId, difficulty, compatibleWithMyEquipment, page, size, sort);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ExerciseCatalogControllerApi->searchExercises: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional]
 **muscleGroupId** | **int**|  | [optional]
 **equipmentId** | **int**|  | [optional]
 **difficulty** | **String**|  | [optional]
 **compatibleWithMyEquipment** | **bool**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]
 **sort** | **String**|  | [optional] [default to 'name,asc']

### Return type

[**ApiResponsePageResponseExerciseSummaryDto**](ApiResponsePageResponseExerciseSummaryDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
