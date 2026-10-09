//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:viegym_api/src/auth/api_key_auth.dart';
import 'package:viegym_api/src/auth/basic_auth.dart';
import 'package:viegym_api/src/auth/bearer_auth.dart';
import 'package:viegym_api/src/auth/oauth.dart';
import 'package:viegym_api/src/api/admin_workout_template_controller_api.dart';
import 'package:viegym_api/src/api/auth_controller_api.dart';
import 'package:viegym_api/src/api/dashboard_controller_api.dart';
import 'package:viegym_api/src/api/exercise_catalog_controller_api.dart';
import 'package:viegym_api/src/api/health_profile_controller_api.dart';
import 'package:viegym_api/src/api/nutrition_controller_api.dart';
import 'package:viegym_api/src/api/personal_record_controller_api.dart';
import 'package:viegym_api/src/api/preference_controller_api.dart';
import 'package:viegym_api/src/api/user_profile_controller_api.dart';
import 'package:viegym_api/src/api/weight_log_controller_api.dart';
import 'package:viegym_api/src/api/workout_log_controller_api.dart';
import 'package:viegym_api/src/api/workout_program_controller_api.dart';
import 'package:viegym_api/src/api/workout_schedule_controller_api.dart';
import 'package:viegym_api/src/api/workout_schedule_planning_controller_api.dart';
import 'package:viegym_api/src/api/workout_session_controller_api.dart';
import 'package:viegym_api/src/api/workout_template_controller_api.dart';

class ViegymApi {
  static const String basePath = r'http://localhost:8080/api/v1';

  final Dio dio;
  ViegymApi({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  }) : this.dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: basePathOverride ?? basePath,
               connectTimeout: const Duration(milliseconds: 5000),
               receiveTimeout: const Duration(milliseconds: 3000),
             ),
           ) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor)
                  as OAuthInterceptor)
              .tokens[name] =
          token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor)
                  as BearerAuthInterceptor)
              .tokens[name] =
          token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor)
              as BasicAuthInterceptor)
          .authInfo[name] = BasicAuthInfo(
        username,
        password,
      );
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere(
                    (element) => element is ApiKeyAuthInterceptor,
                  )
                  as ApiKeyAuthInterceptor)
              .apiKeys[name] =
          apiKey;
    }
  }

  /// Get AdminWorkoutTemplateControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminWorkoutTemplateControllerApi getAdminWorkoutTemplateControllerApi() {
    return AdminWorkoutTemplateControllerApi(dio);
  }

  /// Get AuthControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthControllerApi getAuthControllerApi() {
    return AuthControllerApi(dio);
  }

  /// Get DashboardControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DashboardControllerApi getDashboardControllerApi() {
    return DashboardControllerApi(dio);
  }

  /// Get ExerciseCatalogControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ExerciseCatalogControllerApi getExerciseCatalogControllerApi() {
    return ExerciseCatalogControllerApi(dio);
  }

  /// Get HealthProfileControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  HealthProfileControllerApi getHealthProfileControllerApi() {
    return HealthProfileControllerApi(dio);
  }

  /// Get NutritionControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  NutritionControllerApi getNutritionControllerApi() {
    return NutritionControllerApi(dio);
  }

  /// Get PersonalRecordControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PersonalRecordControllerApi getPersonalRecordControllerApi() {
    return PersonalRecordControllerApi(dio);
  }

  /// Get PreferenceControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PreferenceControllerApi getPreferenceControllerApi() {
    return PreferenceControllerApi(dio);
  }

  /// Get UserProfileControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UserProfileControllerApi getUserProfileControllerApi() {
    return UserProfileControllerApi(dio);
  }

  /// Get WeightLogControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WeightLogControllerApi getWeightLogControllerApi() {
    return WeightLogControllerApi(dio);
  }

  /// Get WorkoutLogControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WorkoutLogControllerApi getWorkoutLogControllerApi() {
    return WorkoutLogControllerApi(dio);
  }

  /// Get WorkoutProgramControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WorkoutProgramControllerApi getWorkoutProgramControllerApi() {
    return WorkoutProgramControllerApi(dio);
  }

  /// Get WorkoutScheduleControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WorkoutScheduleControllerApi getWorkoutScheduleControllerApi() {
    return WorkoutScheduleControllerApi(dio);
  }

  /// Get WorkoutSchedulePlanningControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WorkoutSchedulePlanningControllerApi
  getWorkoutSchedulePlanningControllerApi() {
    return WorkoutSchedulePlanningControllerApi(dio);
  }

  /// Get WorkoutSessionControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WorkoutSessionControllerApi getWorkoutSessionControllerApi() {
    return WorkoutSessionControllerApi(dio);
  }

  /// Get WorkoutTemplateControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WorkoutTemplateControllerApi getWorkoutTemplateControllerApi() {
    return WorkoutTemplateControllerApi(dio);
  }
}
