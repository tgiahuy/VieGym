import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_error_handler.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// Unified widget that handles all [AsyncValue] states:
///   - `loading` → [LoadingView]
///   - `error`   → [ErrorView] with parsed [ApiError] message
///   - `data`    → caller-provided `data` builder
///
/// Usage:
/// ```dart
/// AsyncValueWidget<List<Exercise>>(
///   value: ref.watch(exerciseListProvider),
///   onRetry: () => ref.invalidate(exerciseListProvider),
///   data: (exercises) => ExerciseListView(exercises: exercises),
/// );
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback? onRetry;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (error, stackTrace) => ErrorView(
        message: ApiErrorHandler.getMessage(error),
        onRetry: onRetry,
      ),
      loading: () => LoadingView(message: loadingMessage),
    );
  }
}
