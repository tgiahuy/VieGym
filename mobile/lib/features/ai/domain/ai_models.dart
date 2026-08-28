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

class AiCoachState {
  const AiCoachState({required this.messages, this.isGenerating = false});

  final List<AiChatMessage> messages;
  final bool isGenerating;

  AiCoachState copyWith({List<AiChatMessage>? messages, bool? isGenerating}) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}
