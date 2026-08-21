import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';
import 'loading_view.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback? onRetry;
  final String? loadingMessage;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (e, st) => ErrorView(
        message: e.toString(), // Consider using ApiErrorHandler here
        onRetry: onRetry,
      ),
      loading: () => LoadingView(message: loadingMessage),
    );
  }
}
