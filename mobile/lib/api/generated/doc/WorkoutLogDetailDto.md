# viegym_api.model.WorkoutLogDetailDto

## Load the model package
```dart
import 'package:viegym_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | [optional]
**workoutSessionId** | **int** |  | [optional]
**workoutScheduleId** | **int** |  | [optional]
**title** | **String** |  | [optional]
**startedAt** | [**DateTime**](DateTime.md) |  | [optional]
**completedAt** | [**DateTime**](DateTime.md) |  | [optional]
**durationSeconds** | **int** |  | [optional]
**totalVolumeKg** | **double** |  | [optional]
**note** | **String** |  | [optional]
**exercises** | [**List&lt;WorkoutExerciseLogDto&gt;**](WorkoutExerciseLogDto.md) |  | [optional]
**personalRecords** | [**List&lt;PersonalRecordDto&gt;**](PersonalRecordDto.md) |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
