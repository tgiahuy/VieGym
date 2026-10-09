# viegym_api.api.NutritionControllerApi

## Load the API package
```dart
import 'package:viegym_api/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addEntry**](NutritionControllerApi.md#addentry) | **POST** /api/v1/meal-plans/{planDate}/entries |
[**addFavorite**](NutritionControllerApi.md#addfavorite) | **PUT** /api/v1/favorite-foods/{foodId} |
[**applyTemplate**](NutritionControllerApi.md#applytemplate) | **POST** /api/v1/meal-templates/{id}/apply |
[**createTemplate**](NutritionControllerApi.md#createtemplate) | **POST** /api/v1/meal-templates |
[**deleteEntry**](NutritionControllerApi.md#deleteentry) | **DELETE** /api/v1/meal-plans/{planDate}/entries/{entryId} |
[**deleteTemplate**](NutritionControllerApi.md#deletetemplate) | **DELETE** /api/v1/meal-templates/{id} |
[**favorites**](NutritionControllerApi.md#favorites) | **GET** /api/v1/favorite-foods |
[**food**](NutritionControllerApi.md#food) | **GET** /api/v1/foods/{id} |
[**foods**](NutritionControllerApi.md#foods) | **GET** /api/v1/foods |
[**mealHistory**](NutritionControllerApi.md#mealhistory) | **GET** /api/v1/meal-plans/history |
[**mealPlan**](NutritionControllerApi.md#mealplan) | **GET** /api/v1/meal-plans |
[**removeFavorite**](NutritionControllerApi.md#removefavorite) | **DELETE** /api/v1/favorite-foods/{foodId} |
[**template**](NutritionControllerApi.md#template) | **GET** /api/v1/meal-templates/{id} |
[**templates**](NutritionControllerApi.md#templates) | **GET** /api/v1/meal-templates |
[**updateEntry**](NutritionControllerApi.md#updateentry) | **PUT** /api/v1/meal-plans/{planDate}/entries/{entryId} |
[**updateTemplate**](NutritionControllerApi.md#updatetemplate) | **PUT** /api/v1/meal-templates/{id} |


# **addEntry**
> ApiResponseMealPlan addEntry(planDate, mealEntryRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final DateTime planDate = 2013-10-20; // DateTime |
final MealEntryRequest mealEntryRequest = ; // MealEntryRequest |

try {
    final response = api.addEntry(planDate, mealEntryRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->addEntry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planDate** | **DateTime**|  |
 **mealEntryRequest** | [**MealEntryRequest**](MealEntryRequest.md)|  |

### Return type

[**ApiResponseMealPlan**](ApiResponseMealPlan.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addFavorite**
> ApiResponseVoid addFavorite(foodId)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int foodId = 789; // int |

try {
    final response = api.addFavorite(foodId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->addFavorite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **foodId** | **int**|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **applyTemplate**
> ApiResponseApplyTemplateResult applyTemplate(id, applyMealTemplateRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int id = 789; // int |
final ApplyMealTemplateRequest applyMealTemplateRequest = ; // ApplyMealTemplateRequest |

try {
    final response = api.applyTemplate(id, applyMealTemplateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->applyTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **applyMealTemplateRequest** | [**ApplyMealTemplateRequest**](ApplyMealTemplateRequest.md)|  |

### Return type

[**ApiResponseApplyTemplateResult**](ApiResponseApplyTemplateResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTemplate**
> ApiResponseMealTemplate createTemplate(createMealTemplateRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final CreateMealTemplateRequest createMealTemplateRequest = ; // CreateMealTemplateRequest |

try {
    final response = api.createTemplate(createMealTemplateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->createTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createMealTemplateRequest** | [**CreateMealTemplateRequest**](CreateMealTemplateRequest.md)|  |

### Return type

[**ApiResponseMealTemplate**](ApiResponseMealTemplate.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteEntry**
> deleteEntry(planDate, entryId)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final DateTime planDate = 2013-10-20; // DateTime |
final int entryId = 789; // int |

try {
    api.deleteEntry(planDate, entryId);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->deleteEntry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planDate** | **DateTime**|  |
 **entryId** | **int**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTemplate**
> deleteTemplate(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int id = 789; // int |

try {
    api.deleteTemplate(id);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->deleteTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **favorites**
> ApiResponsePageResponseFood favorites(q, page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final String q = q_example; // String |
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.favorites(q, page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->favorites: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**ApiResponsePageResponseFood**](ApiResponsePageResponseFood.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **food**
> ApiResponseFood food(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int id = 789; // int |

try {
    final response = api.food(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->food: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseFood**](ApiResponseFood.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **foods**
> ApiResponsePageResponseFood foods(q, category, page, size, sort)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final String q = q_example; // String |
final String category = category_example; // String |
final int page = 56; // int |
final int size = 56; // int |
final String sort = sort_example; // String |

try {
    final response = api.foods(q, category, page, size, sort);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->foods: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | [optional]
 **category** | **String**|  | [optional]
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]
 **sort** | **String**|  | [optional] [default to 'name,asc']

### Return type

[**ApiResponsePageResponseFood**](ApiResponsePageResponseFood.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mealHistory**
> ApiResponsePageResponseMealPlan mealHistory(page, size)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int page = 56; // int |
final int size = 56; // int |

try {
    final response = api.mealHistory(page, size);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->mealHistory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 30]

### Return type

[**ApiResponsePageResponseMealPlan**](ApiResponsePageResponseMealPlan.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mealPlan**
> ApiResponseMealPlan mealPlan(date)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final DateTime date = 2013-10-20; // DateTime |

try {
    final response = api.mealPlan(date);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->mealPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **DateTime**|  |

### Return type

[**ApiResponseMealPlan**](ApiResponseMealPlan.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeFavorite**
> ApiResponseVoid removeFavorite(foodId)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int foodId = 789; // int |

try {
    final response = api.removeFavorite(foodId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->removeFavorite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **foodId** | **int**|  |

### Return type

[**ApiResponseVoid**](ApiResponseVoid.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **template**
> ApiResponseMealTemplate template(id)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int id = 789; // int |

try {
    final response = api.template(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->template: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |

### Return type

[**ApiResponseMealTemplate**](ApiResponseMealTemplate.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **templates**
> ApiResponseListMealTemplate templates()



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();

try {
    final response = api.templates();
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->templates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiResponseListMealTemplate**](ApiResponseListMealTemplate.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateEntry**
> ApiResponseMealPlan updateEntry(planDate, entryId, mealEntryRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final DateTime planDate = 2013-10-20; // DateTime |
final int entryId = 789; // int |
final MealEntryRequest mealEntryRequest = ; // MealEntryRequest |

try {
    final response = api.updateEntry(planDate, entryId, mealEntryRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->updateEntry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planDate** | **DateTime**|  |
 **entryId** | **int**|  |
 **mealEntryRequest** | [**MealEntryRequest**](MealEntryRequest.md)|  |

### Return type

[**ApiResponseMealPlan**](ApiResponseMealPlan.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTemplate**
> ApiResponseMealTemplate updateTemplate(id, createMealTemplateRequest)



### Example
```dart
import 'package:viegym_api/api.dart';

final api = ViegymApi().getNutritionControllerApi();
final int id = 789; // int |
final CreateMealTemplateRequest createMealTemplateRequest = ; // CreateMealTemplateRequest |

try {
    final response = api.updateTemplate(id, createMealTemplateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling NutritionControllerApi->updateTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  |
 **createMealTemplateRequest** | [**CreateMealTemplateRequest**](CreateMealTemplateRequest.md)|  |

### Return type

[**ApiResponseMealTemplate**](ApiResponseMealTemplate.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
