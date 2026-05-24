import 'package:fl_croc/common/context.dart';
import 'package:flutter/material.dart';

class NullStatusWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const NullStatusWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
