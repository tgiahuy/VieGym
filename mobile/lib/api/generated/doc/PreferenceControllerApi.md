# viegym_api.api.PreferenceControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**get1**](PreferenceControllerApi.md#get1) | **GET** /api/v1/preferences |
[**getEquipment**](PreferenceControllerApi.md#getequipment) | **GET** /api/v1/preferences/equipment |
[**put**](PreferenceControllerApi.md#put) | **PUT** /api/v1/preferences |
[**putEquipment**](PreferenceControllerApi.md#putequipment) | **PUT** /api/v1/preferences/equipment |


# **get1**
> ApiResponsePreferenceResponse get1()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getPreferenceControllerApi();

try {
    final response = api.get1();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PreferenceControllerApi->get1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponsePreferenceResponse**](ApiResponsePreferenceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEquipment**
> ApiResponseEquipmentPreferenceResponse getEquipment()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getPreferenceControllerApi();

try {
    final response = api.getEquipment();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PreferenceControllerApi->getEquipment: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseEquipmentPreferenceResponse**](ApiResponseEquipmentPreferenceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **put**
> ApiResponsePreferenceResponse put(preferenceRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getPreferenceControllerApi();
final PreferenceRequest preferenceRequest = ; // PreferenceRequest |

try {
    final response = api.put(preferenceRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PreferenceControllerApi->put: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **preferenceRequest** | [**PreferenceRequest**](PreferenceRequest.md)|  |

### Return type

[**ApiResponsePreferenceResponse**](ApiResponsePreferenceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putEquipment**
> ApiResponseEquipmentPreferenceResponse putEquipment(equipmentPreferenceRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getPreferenceControllerApi();
final EquipmentPreferenceRequest equipmentPreferenceRequest = ; // EquipmentPreferenceRequest |

try {
    final response = api.putEquipment(equipmentPreferenceRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PreferenceControllerApi->putEquipment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **equipmentPreferenceRequest** | [**EquipmentPreferenceRequest**](EquipmentPreferenceRequest.md)|  |

### Return type

[**ApiResponseEquipmentPreferenceResponse**](ApiResponseEquipmentPreferenceResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
