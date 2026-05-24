import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentTransfersWidget extends ConsumerWidget {
  const RecentTransfersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transfersProvider);
    final recent = transfers.take(3).toList();

    return SizedBox(
      height: 180,
      child: CommonCard(
        info: const Info(iconData: Icons.history, label: 'Recent Transfers'),
        child: recent.isEmpty
            ? Center(
                child: Text(
                  'No transfers',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: recent.map((t) {
                  final icon = t.direction == TransferDirection.sent
                      ? Icons.upload
                      : Icons.download;
                  final statusColor = _getStatusColor(t.status, context);
                  return ListTile(
                    dense: true,
                    leading: Icon(icon, size: 20),
                    title: Text(
                      t.files.first.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.status.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Color _getStatusColor(TransferStatus status, BuildContext context) {
    switch (status) {
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.transferring:
        return context.colorScheme.primary;
      default:
        return context.colorScheme.onSurfaceVariant;
    }
  }
}
