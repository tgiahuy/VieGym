import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/ai_coach_chat_screen.dart';
import '../../features/ai/presentation/ai_consent_screen.dart';
import '../../features/ai/presentation/ai_tab_screen.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/nutrition/domain/food_models.dart';
import '../../features/nutrition/presentation/ai_meal_generate_screen.dart';
import '../../features/nutrition/presentation/favorite_foods_screen.dart';
import '../../features/nutrition/presentation/food_detail_screen.dart';
import '../../features/nutrition/presentation/food_search_screen.dart';
import '../../features/nutrition/presentation/meal_builder_screen.dart';
import '../../features/nutrition/presentation/meal_history_screen.dart';
import '../../features/nutrition/presentation/meal_planner_screen.dart';
import '../../features/nutrition/presentation/nutrition_screen.dart';
import '../../features/onboarding/presentation/equipment_onboarding_screen.dart';
import '../../features/onboarding/presentation/health_profile_onboarding_screen.dart';
import '../../features/profile/presentation/account_security_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/equipment_preference_screen.dart';
import '../../features/profile/presentation/health_profile_edit_screen.dart';
import '../../features/profile/presentation/personal_records_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/progress_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/user_preference_screen.dart';
import '../../features/profile/presentation/user_profile_screen.dart';
import '../../features/shell/presentation/home_shell.dart';
import '../../features/shell/presentation/not_found_screen.dart';
import '../../features/workout/domain/workout_models.dart';
import '../../features/workout/presentation/ai_workout_generate_screen.dart';
import '../../features/workout/presentation/exercise_detail_screen.dart';
import '../../features/workout/presentation/exercise_library_screen.dart';
import '../../features/workout/presentation/favorite_exercises_screen.dart';
import '../../features/workout/presentation/workout_history_detail_screen.dart';
import '../../features/workout/presentation/workout_history_screen.dart';
import '../../features/workout/presentation/workout_schedule_screen.dart';
import '../../features/workout/presentation/workout_session_screen.dart';
import '../../features/workout/presentation/workout_summary_screen.dart';
import '../../features/workout/presentation/workout_swap_schedule_screen.dart';
import '../../features/workout/presentation/workout_tab_screen.dart';
import '../../shared/widgets/auth_video_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) =>
        NotFoundScreen(errorMessage: state.error?.toString()),
    routes: [
      // Authentication routes share one persistent video background.
      ShellRoute(
        builder: (context, state, child) => AuthVideoShell(child: child),
        routes: [
          GoRoute(
            path: '/splash',
            name: 'splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/welcome',
            name: 'welcome',
            builder: (context, state) => const WelcomeScreen(),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: '/otp',
            name: 'otp',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final email = extra?['email'] as String? ??
                  state.uri.queryParameters['email'];
              final purposeVal = extra?['purpose'] ??
                  state.uri.queryParameters['purpose'];
              final purpose = purposeVal is OtpPurpose
                  ? purposeVal
                  : (purposeVal == 'passwordReset'
                      ? OtpPurpose.passwordReset
                      : OtpPurpose.register);
              return OtpScreen(email: email, purpose: purpose);
            },
          ),
          GoRoute(
            path: '/reset-password',
            name: 'reset-password',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final email = extra?['email'] as String? ??
                  state.uri.queryParameters['email'];
              return ResetPasswordScreen(email: email);
            },
          ),
        ],
      ),

      // Onboarding uses the regular app background without video.
      GoRoute(
        path: '/onboarding/health',
        name: 'onboarding-health',
        builder: (context, state) => const HealthProfileOnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/equipment',
        name: 'onboarding-equipment',
        builder: (context, state) => const EquipmentOnboardingScreen(),
      ),

      // Main Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workout',
                name: 'workout',
                builder: (context, state) => const WorkoutTabScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/meal',
                name: 'nutrition',
                builder: (context, state) => const NutritionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                name: 'ai',
                builder: (context, state) => const AiTabScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Workout Sub-Routes
      GoRoute(
        path: '/workout/session',
        name: 'workout-session',
        builder: (context, state) => const WorkoutSessionScreen(),
      ),
      GoRoute(
        path: '/workout/summary',
        name: 'workout-summary',
        builder: (context, state) {
          final summary = state.extra as WorkoutSummaryData?;
          return WorkoutSummaryScreen(summary: summary);
        },
      ),
      GoRoute(
        path: '/workout/library',
        name: 'exercise-library',
        builder: (context, state) {
          final isPicker = state.uri.queryParameters['select'] == 'true';
          final isMulti = state.uri.queryParameters['multi'] == 'true';
          final title =
              state.uri.queryParameters['title'] ?? 'Thư viện bài tập';
          return ExerciseLibraryScreen(
            isPicker: isPicker,
            isMultiSelect: isMulti,
            title: title,
          );
        },
      ),
      GoRoute(
        path: '/workout/schedule',
        name: 'workout-schedule',
        builder: (context, state) => const WorkoutScheduleScreen(),
      ),
      GoRoute(
        path: '/workout/schedule/swap',
        name: 'workout-swap-schedule',
        builder: (context, state) {
          final sourceId = state.uri.queryParameters['sourceId'];
          return WorkoutSwapScheduleScreen(sourceScheduleId: sourceId);
        },
      ),
      GoRoute(
        path: '/workout/history',
        name: 'workout-history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: '/workout/history/detail',
        name: 'workout-history-detail',
        builder: (context, state) {
          final historyId = state.uri.queryParameters['id'] ?? '';
          return WorkoutHistoryDetailScreen(historyId: historyId);
        },
      ),
      GoRoute(
        path: '/workout/generate',
        name: 'workout-generate',
        builder: (context, state) => const AiWorkoutGenerateScreen(),
      ),
      GoRoute(
        path: '/workout/favorites',
        name: 'workout-favorites',
        builder: (context, state) => const FavoriteExercisesScreen(),
      ),
      GoRoute(
        path: '/exercise/:id',
        name: 'exercise-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'ex1';
          return ExerciseDetailScreen(exerciseId: id);
        },
      ),

      // Nutrition Sub-Routes
      GoRoute(
        path: '/meal/search',
        name: 'meal-search',
        builder: (context, state) {
          final mealTypeStr = state.uri.queryParameters['mealType'];
          final mealType = MealType.values.firstWhere(
            (m) => m.code == mealTypeStr,
            orElse: () => MealType.lunch,
          );
          return FoodSearchScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/meal/food/:id',
        name: 'food-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'food_pho_bo';
          final mealTypeStr = state.uri.queryParameters['mealType'];
          final mealType = MealType.values.firstWhere(
            (m) => m.code == mealTypeStr,
            orElse: () => MealType.lunch,
          );
          return FoodDetailScreen(foodId: id, initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/meal/builder',
        name: 'meal-builder',
        builder: (context, state) {
          final mealTypeStr = state.uri.queryParameters['mealType'];
          final mealType = MealType.values.firstWhere(
            (m) => m.code == mealTypeStr,
            orElse: () => MealType.lunch,
          );
          return MealBuilderScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/meal/generate',
        name: 'meal-generate',
        builder: (context, state) {
          final mealTypeStr = state.uri.queryParameters['mealType'];
          final mealType = MealType.values
              .where((m) => m.code == mealTypeStr)
              .firstOrNull;
          return AiMealGenerateScreen(initialMealType: mealType);
        },
      ),
      GoRoute(
        path: '/meal/plan',
        name: 'meal-plan',
        builder: (context, state) => const MealPlannerScreen(),
      ),
      GoRoute(
        path: '/nutrition/favorites',
        name: 'nutrition-favorites',
        builder: (context, state) => const FavoriteFoodsScreen(),
      ),
      GoRoute(
        path: '/meal/favorites',
        name: 'meal-favorites',
        builder: (context, state) => const FavoriteFoodsScreen(),
      ),
      GoRoute(
        path: '/meal/history',
        name: 'meal-history',
        builder: (context, state) => const MealHistoryScreen(),
      ),

      // Profile & Progress Sub-Routes
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/profile/user',
        name: 'profile-user',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/health',
        name: 'profile-health',
        builder: (context, state) => const HealthProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile/equipment',
        name: 'profile-equipment',
        builder: (context, state) => const EquipmentPreferenceScreen(),
      ),
      GoRoute(
        path: '/profile/records',
        name: 'profile-records',
        builder: (context, state) => const PersonalRecordsScreen(),
      ),
      GoRoute(
        path: '/profile/preferences',
        name: 'profile-preferences',
        builder: (context, state) => const UserPreferenceScreen(),
      ),
      GoRoute(
        path: '/profile/settings/preferences',
        name: 'profile-settings-preferences',
        builder: (context, state) => const UserPreferenceScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        name: 'profile-settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/security',
        name: 'profile-security',
        builder: (context, state) => const AccountSecurityScreen(),
      ),

      // AI Sub-Routes
      GoRoute(
        path: '/ai/chat',
        name: 'ai-chat',
        builder: (context, state) => const AiCoachChatScreen(),
      ),
      GoRoute(
        path: '/ai/consent',
        name: 'ai-consent',
        builder: (context, state) => const AiConsentScreen(),
      ),
    ],
  );
}, name: 'routerProvider');
