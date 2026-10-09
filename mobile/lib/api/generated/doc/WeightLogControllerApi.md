# viegym_api.api.WeightLogControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**list**](WeightLogControllerApi.md#list) | **GET** /api/v1/weight-logs |
[**trend**](WeightLogControllerApi.md#trend) | **GET** /api/v1/weight-logs/trend |
[**upsert**](WeightLogControllerApi.md#upsert) | **PUT** /api/v1/weight-logs/{loggedDate} |


# **list**
> ApiResponsePageResponseWeightLogDto list(from, to, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWeightLogControllerApi();
final DateTime from = 2013-10-20; // DateTime |
final DateTime to = 2013-10-20; // DateTime |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.list(from, to, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WeightLogControllerApi->list: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **DateTime**|  | [optional]
 **to** | **DateTime**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponseWeightLogDto**](ApiResponsePageResponseWeightLogDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **trend**
> ApiResponseWeightTrendResponse trend(days)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWeightLogControllerApi();
final int days = 56; // int |

try {
    final response = api.trend(days);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WeightLogControllerApi->trend: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 30]

### Return type

[**ApiResponseWeightTrendResponse**](ApiResponseWeightTrendResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsert**
> ApiResponseUpsertWeightLogResponse upsert(loggedDate, upsertWeightLogRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getWeightLogControllerApi();
final DateTime loggedDate = 2013-10-20; // DateTime |
final UpsertWeightLogRequest upsertWeightLogRequest = ; // UpsertWeightLogRequest |

try {
    final response = api.upsert(loggedDate, upsertWeightLogRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling WeightLogControllerApi->upsert: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loggedDate** | **DateTime**|  |
 **upsertWeightLogRequest** | [**UpsertWeightLogRequest**](UpsertWeightLogRequest.md)|  |

### Return type

[**ApiResponseUpsertWeightLogResponse**](ApiResponseUpsertWeightLogResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
