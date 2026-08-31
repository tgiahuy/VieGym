enum ProposalStatus { pending, applied, dismissed }

sealed class AiProposal {
  const AiProposal({required this.id, required this.status});

  final String id;
  final ProposalStatus status;
}

class AlternativeExerciseItem {
  const AlternativeExerciseItem({
    required this.exerciseId,
    required this.name,
    required this.targetMuscles,
    required this.equipment,
    required this.reason,
    required this.equipmentMatch,
  });

  final String exerciseId;
  final String name;
  final List<String> targetMuscles;
  final String equipment;
  final String reason;
  final bool equipmentMatch;
}

class AlternativeExerciseProposal extends AiProposal {
  const AlternativeExerciseProposal({
    required super.id,
    required super.status,
    required this.originalExerciseId,
    required this.originalExerciseName,
    required this.targetMuscles,
    required this.alternatives,
    required this.warning,
    this.selectedExerciseId,
  });

  final String originalExerciseId;
  final String originalExerciseName;
  final List<String> targetMuscles;
  final List<AlternativeExerciseItem> alternatives;
  final String warning;
  final String? selectedExerciseId;

  AlternativeExerciseProposal copyWith({
    ProposalStatus? status,
    String? selectedExerciseId,
  }) {
    return AlternativeExerciseProposal(
      id: id,
      status: status ?? this.status,
      originalExerciseId: originalExerciseId,
      originalExerciseName: originalExerciseName,
      targetMuscles: targetMuscles,
      alternatives: alternatives,
      warning: warning,
      selectedExerciseId: selectedExerciseId ?? this.selectedExerciseId,
    );
  }
}

class MealProposalItem {
  const MealProposalItem({
    required this.name,
    required this.serving,
    required this.calories,
    required this.protein,
  });

  final String name;
  final String serving;
  final int calories;
  final double protein;
}

class MealProposal extends AiProposal {
  const MealProposal({
    required super.id,
    required super.status,
    required this.mealName,
    required this.items,
    required this.reason,
  });

  final String mealName;
  final List<MealProposalItem> items;
  final String reason;

  int get totalCalories => items.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => items.fold(0, (sum, item) => sum + item.protein);

  MealProposal copyWith({ProposalStatus? status}) {
    return MealProposal(
      id: id,
      status: status ?? this.status,
      mealName: mealName,
      items: items,
      reason: reason,
    );
  }
}

class WorkoutProposalItem {
  const WorkoutProposalItem({
    required this.name,
    required this.targetMuscle,
    required this.setsReps,
    required this.restSeconds,
  });

  final String name;
  final String targetMuscle;
  final String setsReps;
  final int restSeconds;
}

class WorkoutProposal extends AiProposal {
  const WorkoutProposal({
    required super.id,
    required super.status,
    required this.workoutTitle,
    required this.focusArea,
    required this.durationMinutes,
    required this.items,
    required this.reason,
  });

  final String workoutTitle;
  final String focusArea;
  final int durationMinutes;
  final List<WorkoutProposalItem> items;
  final String reason;

  WorkoutProposal copyWith({ProposalStatus? status}) {
    return WorkoutProposal(
      id: id,
      status: status ?? this.status,
      workoutTitle: workoutTitle,
      focusArea: focusArea,
      durationMinutes: durationMinutes,
      items: items,
      reason: reason,
    );
  }
}

enum AiMessageSender { user, assistant }

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.proposal,
  });

  final String id;
  final AiMessageSender sender;
  final String text;
  final AiProposal? proposal;

  AiChatMessage copyWith({AiProposal? proposal}) {
    return AiChatMessage(
      id: id,
      sender: sender,
      text: text,
      proposal: proposal ?? this.proposal,
    );
  }
}

enum RecommendationType {
  workout,
  recovery,
  fatigueDeload,
  trainingBalance,
  schedule,
  nutrition,
}

enum RecommendationActionType {
  startWorkout,
  applySchedule,
  adjustNutrition,
  viewRecovery,
}

class AiRecommendation {
  const AiRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    required this.actionType,
    this.status = ProposalStatus.pending,
    this.targetMuscles = const [],
    this.recoveryPercent,
    this.durationMinutes,
    this.createdAt,
    this.metadata,
  });

  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String reason;
  final RecommendationActionType actionType;
  final ProposalStatus status;
  final List<String> targetMuscles;
  final int? recoveryPercent;
  final int? durationMinutes;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  AiRecommendation copyWith({
    ProposalStatus? status,
    String? title,
    String? description,
    String? reason,
  }) {
    return AiRecommendation(
      id: id,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      actionType: actionType,
      status: status ?? this.status,
      targetMuscles: targetMuscles,
      recoveryPercent: recoveryPercent,
      durationMinutes: durationMinutes,
      createdAt: createdAt,
      metadata: metadata,
    );
  }
}

class AiCoachState {
  const AiCoachState({
    required this.messages,
    this.recommendations = const [],
    this.isGenerating = false,
    this.isLoadingRecommendations = false,
  });

  final List<AiChatMessage> messages;
  final List<AiRecommendation> recommendations;
  final bool isGenerating;
  final bool isLoadingRecommendations;

  List<AiRecommendation> get activeRecommendations =>
      recommendations.where((r) => r.status == ProposalStatus.pending).toList();

  int get newRecommendationsCount => activeRecommendations.length;

  AiCoachState copyWith({
    List<AiChatMessage>? messages,
    List<AiRecommendation>? recommendations,
    bool? isGenerating,
    bool? isLoadingRecommendations,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      recommendations: recommendations ?? this.recommendations,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingRecommendations:
          isLoadingRecommendations ?? this.isLoadingRecommendations,
    );
  }
}
