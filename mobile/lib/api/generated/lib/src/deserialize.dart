import 'package:viegym_api/src/model/api_response_apply_schedule_proposal_response.dart';
import 'package:viegym_api/src/model/api_response_apply_template_result.dart';
import 'package:viegym_api/src/model/api_response_dashboard_response.dart';
import 'package:viegym_api/src/model/api_response_equipment_preference_response.dart';
import 'package:viegym_api/src/model/api_response_exercise_detail_dto.dart';
import 'package:viegym_api/src/model/api_response_finish_session_response.dart';
import 'package:viegym_api/src/model/api_response_food.dart';
import 'package:viegym_api/src/model/api_response_health_profile_response.dart';
import 'package:viegym_api/src/model/api_response_list_equipment_dto.dart';
import 'package:viegym_api/src/model/api_response_list_exercise_summary_dto.dart';
import 'package:viegym_api/src/model/api_response_list_meal_template.dart';
import 'package:viegym_api/src/model/api_response_list_muscle_group_dto.dart';
import 'package:viegym_api/src/model/api_response_list_workout_template_response.dart';
import 'package:viegym_api/src/model/api_response_meal_plan.dart';
import 'package:viegym_api/src/model/api_response_meal_template.dart';
import 'package:viegym_api/src/model/api_response_page_response_exercise_summary_dto.dart';
import 'package:viegym_api/src/model/api_response_page_response_food.dart';
import 'package:viegym_api/src/model/api_response_page_response_meal_plan.dart';
import 'package:viegym_api/src/model/api_response_page_response_personal_record_dto.dart';
import 'package:viegym_api/src/model/api_response_page_response_weight_log_dto.dart';
import 'package:viegym_api/src/model/api_response_page_response_workout_log_summary_dto.dart';
import 'package:viegym_api/src/model/api_response_page_response_workout_program_summary_response.dart';
import 'package:viegym_api/src/model/api_response_page_response_workout_schedule_response.dart';
import 'package:viegym_api/src/model/api_response_pause_session_response.dart';
import 'package:viegym_api/src/model/api_response_preference_response.dart';
import 'package:viegym_api/src/model/api_response_register_challenge_response.dart';
import 'package:viegym_api/src/model/api_response_resume_session_response.dart';
import 'package:viegym_api/src/model/api_response_schedule_proposal_response.dart';
import 'package:viegym_api/src/model/api_response_session_response.dart';
import 'package:viegym_api/src/model/api_response_start_session_response.dart';
import 'package:viegym_api/src/model/api_response_upsert_weight_log_response.dart';
import 'package:viegym_api/src/model/api_response_user_response.dart';
import 'package:viegym_api/src/model/api_response_void.dart';
import 'package:viegym_api/src/model/api_response_weight_trend_response.dart';
import 'package:viegym_api/src/model/api_response_workout_log_detail_dto.dart';
import 'package:viegym_api/src/model/api_response_workout_program_response.dart';
import 'package:viegym_api/src/model/api_response_workout_schedule_response.dart';
import 'package:viegym_api/src/model/api_response_workout_template_response.dart';
import 'package:viegym_api/src/model/apply_meal_template_request.dart';
import 'package:viegym_api/src/model/apply_schedule_proposal_response.dart';
import 'package:viegym_api/src/model/apply_template_result.dart';
import 'package:viegym_api/src/model/avatar_response.dart';
import 'package:viegym_api/src/model/body_section.dart';
import 'package:viegym_api/src/model/change_password_request.dart';
import 'package:viegym_api/src/model/create_health_profile_request.dart';
import 'package:viegym_api/src/model/create_meal_template_request.dart';
import 'package:viegym_api/src/model/create_schedule_proposal_request.dart';
import 'package:viegym_api/src/model/dashboard_response.dart';
import 'package:viegym_api/src/model/discard_session_request.dart';
import 'package:viegym_api/src/model/equipment_dto.dart';
import 'package:viegym_api/src/model/equipment_item.dart';
import 'package:viegym_api/src/model/equipment_preference_request.dart';
import 'package:viegym_api/src/model/equipment_preference_response.dart';
import 'package:viegym_api/src/model/exercise_detail_dto.dart';
import 'package:viegym_api/src/model/exercise_equipment_dto.dart';
import 'package:viegym_api/src/model/exercise_muscle_group_dto.dart';
import 'package:viegym_api/src/model/exercise_summary_dto.dart';
import 'package:viegym_api/src/model/facebook_login_request.dart';
import 'package:viegym_api/src/model/finish_exercise_log_request.dart';
import 'package:viegym_api/src/model/finish_session_request.dart';
import 'package:viegym_api/src/model/finish_session_response.dart';
import 'package:viegym_api/src/model/finish_set_log_request.dart';
import 'package:viegym_api/src/model/food.dart';
import 'package:viegym_api/src/model/forgot_password_request.dart';
import 'package:viegym_api/src/model/google_login_request.dart';
import 'package:viegym_api/src/model/health_profile_response.dart';
import 'package:viegym_api/src/model/item.dart';
import 'package:viegym_api/src/model/login_request.dart';
import 'package:viegym_api/src/model/logout_request.dart';
import 'package:viegym_api/src/model/meal.dart';
import 'package:viegym_api/src/model/meal_entry.dart';
import 'package:viegym_api/src/model/meal_entry_request.dart';
import 'package:viegym_api/src/model/meal_plan.dart';
import 'package:viegym_api/src/model/meal_template.dart';
import 'package:viegym_api/src/model/metrics.dart';
import 'package:viegym_api/src/model/muscle_group_dto.dart';
import 'package:viegym_api/src/model/nutrition.dart';
import 'package:viegym_api/src/model/nutrition_macro_summary.dart';
import 'package:viegym_api/src/model/nutrition_section.dart';
import 'package:viegym_api/src/model/nutrition_target.dart';
import 'package:viegym_api/src/model/onboarding_response.dart';
import 'package:viegym_api/src/model/otp_resend_request.dart';
import 'package:viegym_api/src/model/otp_verify_request.dart';
import 'package:viegym_api/src/model/page_response_exercise_summary_dto.dart';
import 'package:viegym_api/src/model/page_response_food.dart';
import 'package:viegym_api/src/model/page_response_meal_plan.dart';
import 'package:viegym_api/src/model/page_response_personal_record_dto.dart';
import 'package:viegym_api/src/model/page_response_weight_log_dto.dart';
import 'package:viegym_api/src/model/page_response_workout_log_summary_dto.dart';
import 'package:viegym_api/src/model/page_response_workout_program_summary_response.dart';
import 'package:viegym_api/src/model/page_response_workout_schedule_response.dart';
import 'package:viegym_api/src/model/pause_session_response.dart';
import 'package:viegym_api/src/model/personal_record_dto.dart';
import 'package:viegym_api/src/model/preference_request.dart';
import 'package:viegym_api/src/model/preference_response.dart';
import 'package:viegym_api/src/model/profile.dart';
import 'package:viegym_api/src/model/refresh_request.dart';
import 'package:viegym_api/src/model/register_challenge_response.dart';
import 'package:viegym_api/src/model/register_request.dart';
import 'package:viegym_api/src/model/reset_password_request.dart';
import 'package:viegym_api/src/model/resume_session_response.dart';
import 'package:viegym_api/src/model/schedule_exercise_plan.dart';
import 'package:viegym_api/src/model/schedule_proposal_item_request.dart';
import 'package:viegym_api/src/model/schedule_proposal_item_response.dart';
import 'package:viegym_api/src/model/schedule_proposal_response.dart';
import 'package:viegym_api/src/model/serving.dart';
import 'package:viegym_api/src/model/session_response.dart';
import 'package:viegym_api/src/model/start_session_response.dart';
import 'package:viegym_api/src/model/template_item.dart';
import 'package:viegym_api/src/model/update_health_profile_request.dart';
import 'package:viegym_api/src/model/update_user_request.dart';
import 'package:viegym_api/src/model/upsert_weight_log_request.dart';
import 'package:viegym_api/src/model/upsert_weight_log_response.dart';
import 'package:viegym_api/src/model/user_response.dart';
import 'package:viegym_api/src/model/weight_log_dto.dart';
import 'package:viegym_api/src/model/weight_trend_point.dart';
import 'package:viegym_api/src/model/weight_trend_response.dart';
import 'package:viegym_api/src/model/workout_completion.dart';
import 'package:viegym_api/src/model/workout_day_request.dart';
import 'package:viegym_api/src/model/workout_day_response.dart';
import 'package:viegym_api/src/model/workout_exercise_log_dto.dart';
import 'package:viegym_api/src/model/workout_exercise_request.dart';
import 'package:viegym_api/src/model/workout_exercise_response.dart';
import 'package:viegym_api/src/model/workout_log_detail_dto.dart';
import 'package:viegym_api/src/model/workout_log_summary_dto.dart';
import 'package:viegym_api/src/model/workout_program_request.dart';
import 'package:viegym_api/src/model/workout_program_response.dart';
import 'package:viegym_api/src/model/workout_program_summary_response.dart';
import 'package:viegym_api/src/model/workout_schedule_request.dart';
import 'package:viegym_api/src/model/workout_schedule_response.dart';
import 'package:viegym_api/src/model/workout_section.dart';
import 'package:viegym_api/src/model/workout_set_log_dto.dart';
import 'package:viegym_api/src/model/workout_template_day_request.dart';
import 'package:viegym_api/src/model/workout_template_day_response.dart';
import 'package:viegym_api/src/model/workout_template_request.dart';
import 'package:viegym_api/src/model/workout_template_response.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'ApiResponseApplyScheduleProposalResponse':
      return ApiResponseApplyScheduleProposalResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseApplyTemplateResult':
      return ApiResponseApplyTemplateResult.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseDashboardResponse':
      return ApiResponseDashboardResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseEquipmentPreferenceResponse':
      return ApiResponseEquipmentPreferenceResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseExerciseDetailDto':
      return ApiResponseExerciseDetailDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseFinishSessionResponse':
      return ApiResponseFinishSessionResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseFood':
      return ApiResponseFood.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseHealthProfileResponse':
      return ApiResponseHealthProfileResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseListEquipmentDto':
      return ApiResponseListEquipmentDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseListExerciseSummaryDto':
      return ApiResponseListExerciseSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseListMealTemplate':
      return ApiResponseListMealTemplate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseListMuscleGroupDto':
      return ApiResponseListMuscleGroupDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseListWorkoutTemplateResponse':
      return ApiResponseListWorkoutTemplateResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseMealPlan':
      return ApiResponseMealPlan.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseMealTemplate':
      return ApiResponseMealTemplate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponsePageResponseExerciseSummaryDto':
      return ApiResponsePageResponseExerciseSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePageResponseFood':
      return ApiResponsePageResponseFood.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponsePageResponseMealPlan':
      return ApiResponsePageResponseMealPlan.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePageResponsePersonalRecordDto':
      return ApiResponsePageResponsePersonalRecordDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePageResponseWeightLogDto':
      return ApiResponsePageResponseWeightLogDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePageResponseWorkoutLogSummaryDto':
      return ApiResponsePageResponseWorkoutLogSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePageResponseWorkoutProgramSummaryResponse':
      return ApiResponsePageResponseWorkoutProgramSummaryResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePageResponseWorkoutScheduleResponse':
      return ApiResponsePageResponseWorkoutScheduleResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePauseSessionResponse':
      return ApiResponsePauseSessionResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponsePreferenceResponse':
      return ApiResponsePreferenceResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseRegisterChallengeResponse':
      return ApiResponseRegisterChallengeResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseResumeSessionResponse':
      return ApiResponseResumeSessionResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseScheduleProposalResponse':
      return ApiResponseScheduleProposalResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseSessionResponse':
      return ApiResponseSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseStartSessionResponse':
      return ApiResponseStartSessionResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseUpsertWeightLogResponse':
      return ApiResponseUpsertWeightLogResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseUserResponse':
      return ApiResponseUserResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseVoid':
      return ApiResponseVoid.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApiResponseWeightTrendResponse':
      return ApiResponseWeightTrendResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseWorkoutLogDetailDto':
      return ApiResponseWorkoutLogDetailDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseWorkoutProgramResponse':
      return ApiResponseWorkoutProgramResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseWorkoutScheduleResponse':
      return ApiResponseWorkoutScheduleResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApiResponseWorkoutTemplateResponse':
      return ApiResponseWorkoutTemplateResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApplyMealTemplateRequest':
      return ApplyMealTemplateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ApplyScheduleProposalResponse':
      return ApplyScheduleProposalResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ApplyTemplateResult':
      return ApplyTemplateResult.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AvatarResponse':
      return AvatarResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'BodySection':
      return BodySection.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ChangePasswordRequest':
      return ChangePasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateHealthProfileRequest':
      return CreateHealthProfileRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateMealTemplateRequest':
      return CreateMealTemplateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateScheduleProposalRequest':
      return CreateScheduleProposalRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'DashboardResponse':
      return DashboardResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DiscardSessionRequest':
      return DiscardSessionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentDto':
      return EquipmentDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'EquipmentItem':
      return EquipmentItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentPreferenceRequest':
      return EquipmentPreferenceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentPreferenceResponse':
      return EquipmentPreferenceResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExerciseDetailDto':
      return ExerciseDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExerciseEquipmentDto':
      return ExerciseEquipmentDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExerciseMuscleGroupDto':
      return ExerciseMuscleGroupDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExerciseSummaryDto':
      return ExerciseSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FacebookLoginRequest':
      return FacebookLoginRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FinishExerciseLogRequest':
      return FinishExerciseLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FinishSessionRequest':
      return FinishSessionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FinishSessionResponse':
      return FinishSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FinishSetLogRequest':
      return FinishSetLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Food':
      return Food.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ForgotPasswordRequest':
      return ForgotPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GoogleLoginRequest':
      return GoogleLoginRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthProfileResponse':
      return HealthProfileResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Item':
      return Item.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginRequest':
      return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LogoutRequest':
      return LogoutRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Meal':
      return Meal.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealEntry':
      return MealEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealEntryRequest':
      return MealEntryRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealPlan':
      return MealPlan.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealTemplate':
      return MealTemplate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Metrics':
      return Metrics.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MuscleGroupDto':
      return MuscleGroupDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Nutrition':
      return Nutrition.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'NutritionMacroSummary':
      return NutritionMacroSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NutritionSection':
      return NutritionSection.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NutritionTarget':
      return NutritionTarget.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OnboardingResponse':
      return OnboardingResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpResendRequest':
      return OtpResendRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpVerifyRequest':
      return OtpVerifyRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PageResponseExerciseSummaryDto':
      return PageResponseExerciseSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PageResponseFood':
      return PageResponseFood.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PageResponseMealPlan':
      return PageResponseMealPlan.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PageResponsePersonalRecordDto':
      return PageResponsePersonalRecordDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PageResponseWeightLogDto':
      return PageResponseWeightLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PageResponseWorkoutLogSummaryDto':
      return PageResponseWorkoutLogSummaryDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PageResponseWorkoutProgramSummaryResponse':
      return PageResponseWorkoutProgramSummaryResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PageResponseWorkoutScheduleResponse':
      return PageResponseWorkoutScheduleResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PauseSessionResponse':
      return PauseSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PersonalRecordDto':
      return PersonalRecordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PreferenceRequest':
      return PreferenceRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PreferenceResponse':
      return PreferenceResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Profile':
      return Profile.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RefreshRequest':
      return RefreshRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterChallengeResponse':
      return RegisterChallengeResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterRequest':
      return RegisterRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResetPasswordRequest':
      return ResetPasswordRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResumeSessionResponse':
      return ResumeSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ScheduleExercisePlan':
      return ScheduleExercisePlan.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ScheduleProposalItemRequest':
      return ScheduleProposalItemRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ScheduleProposalItemResponse':
      return ScheduleProposalItemResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'ScheduleProposalResponse':
      return ScheduleProposalResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Serving':
      return Serving.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SessionResponse':
      return SessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StartSessionResponse':
      return StartSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TemplateItem':
      return TemplateItem.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UpdateHealthProfileRequest':
      return UpdateHealthProfileRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateUserRequest':
      return UpdateUserRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpsertWeightLogRequest':
      return UpsertWeightLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpsertWeightLogResponse':
      return UpsertWeightLogResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UserResponse':
      return UserResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WeightLogDto':
      return WeightLogDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WeightTrendPoint':
      return WeightTrendPoint.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeightTrendResponse':
      return WeightTrendResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutCompletion':
      return WorkoutCompletion.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutDayRequest':
      return WorkoutDayRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutDayResponse':
      return WorkoutDayResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutExerciseLogDto':
      return WorkoutExerciseLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutExerciseRequest':
      return WorkoutExerciseRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutExerciseResponse':
      return WorkoutExerciseResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutLogDetailDto':
      return WorkoutLogDetailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutLogSummaryDto':
      return WorkoutLogSummaryDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutProgramRequest':
      return WorkoutProgramRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutProgramResponse':
      return WorkoutProgramResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutProgramSummaryResponse':
      return WorkoutProgramSummaryResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'WorkoutScheduleRequest':
      return WorkoutScheduleRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutScheduleResponse':
      return WorkoutScheduleResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutSection':
      return WorkoutSection.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutSetLogDto':
      return WorkoutSetLogDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutTemplateDayRequest':
      return WorkoutTemplateDayRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutTemplateDayResponse':
      return WorkoutTemplateDayResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutTemplateRequest':
      return WorkoutTemplateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutTemplateResponse':
      return WorkoutTemplateResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
