import 'package:flutter/material.dart';

/// A network image that keeps its layout stable while loading and provides a
/// consistent fallback when the device is offline or the dataset URL is bad.
class ResilientNetworkImage extends StatelessWidget {
  const ResilientNetworkImage({
    super.key,
    required this.url,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholderIcon = Icons.image_not_supported_outlined,
  });

  final String url;
  final String semanticLabel;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget placeholder({bool isLoading = false, double? progress}) {
      return ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: !isLoading
              ? Icon(
                  placeholderIcon,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                )
              : SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    color: colors.primary,
                    backgroundColor: colors.outlineVariant,
                  ),
                ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        fit: fit,
        semanticLabel: semanticLabel,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, event) {
          if (event == null) return child;
          final total = event.expectedTotalBytes;
          return placeholder(
            isLoading: true,
            progress: total == null
                ? null
                : event.cumulativeBytesLoaded / total,
          );
        },
        errorBuilder: (context, error, stackTrace) => placeholder(),
      ),
    );
  }
}
