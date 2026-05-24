import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrocStatusWidget extends ConsumerWidget {
  const CrocStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coreStatus = ref.watch(coreStatusProvider);

    return SizedBox(
      height: 120,
      child: CommonCard(
        info: const Info(iconData: Icons.link, label: 'Croc Status'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(coreStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      coreStatus.name,
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'croc v10.4.4',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CoreStatus status) {
    switch (status) {
      case CoreStatus.connected:
        return Colors.green;
      case CoreStatus.connecting:
        return Colors.orange;
      case CoreStatus.error:
        return Colors.red;
      case CoreStatus.disconnected:
        return Colors.grey;
    }
  }
}
