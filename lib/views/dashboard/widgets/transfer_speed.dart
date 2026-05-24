import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferSpeedWidget extends ConsumerWidget {
  const TransferSpeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speeds = ref.watch(appStateProvider).speeds;
    final totalSpeed =
        speeds.values.fold<double>(0, (a, b) => a + b);

    return SizedBox(
      height: 120,
      child: CommonCard(
        info: const Info(iconData: Icons.speed, label: 'Transfer Speed'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              totalSpeed.transferSpeed,
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${speeds.length} active',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
