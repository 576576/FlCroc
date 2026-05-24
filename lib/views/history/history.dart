import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transfersProvider);
    final completed = transfers
        .where((t) =>
            t.status == TransferStatus.completed ||
            t.status == TransferStatus.failed ||
            t.status == TransferStatus.cancelled)
        .toList();

    return BaseScaffold(
      title: 'History',
      actions: [
        if (completed.isNotEmpty)
          IconButton(
            onPressed: () {
              appController.clearHistory();
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
      ],
      body: completed.isEmpty
          ? const NullStatusWidget(
              message: 'No history',
              icon: Icons.history,
            )
          : ListView.builder(
              itemCount: completed.length,
              itemBuilder: (_, index) {
                final transfer = completed[index];
                final isSent = transfer.direction == TransferDirection.sent;
                return ListTile(
                  leading: Icon(
                    isSent ? Icons.upload_file : Icons.download,
                    color: isSent ? Colors.blue : Colors.green,
                  ),
                  title: Text(
                    transfer.files.map((f) => f.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${transfer.totalSize.fileSize} • ${transfer.startTime.timeAgo}',
                  ),
                  trailing: _buildStatusChip(transfer.status, context),
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(TransferStatus status, BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TransferStatus.completed:
        color = Colors.green;
        label = 'Done';
        break;
      case TransferStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
      case TransferStatus.cancelled:
        color = Colors.orange;
        label = 'Cancelled';
        break;
      default:
        color = context.colorScheme.primary;
        label = status.name;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
