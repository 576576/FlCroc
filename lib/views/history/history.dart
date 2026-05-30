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
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final l10n = context.appLocalizations;

    return BaseScaffold(
      title: l10n.history,
      actions: [
        if (completed.isNotEmpty)
          FilledButton.icon(
            onPressed: () => appController.clearHistory(),
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(l10n.clear),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        const SizedBox(width: 8),
      ],
      body: completed.isEmpty
          ? NullStatusWidget(
              message: l10n.noHistory,
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
                    '${transfer.totalSize.fileSize} • ${transfer.startTime.timeAgoL10n(l10n)}',
                  ),
                  trailing: _buildStatusChip(transfer.status, context),
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(TransferStatus status, BuildContext context) {
    final l10n = context.appLocalizations;
    Color color;
    String label;
    switch (status) {
      case TransferStatus.completed:
        color = Colors.green;
        label = l10n.completed;
        break;
      case TransferStatus.failed:
        color = Colors.red;
        label = l10n.failed;
        break;
      case TransferStatus.cancelled:
        color = Colors.orange;
        label = l10n.cancelled;
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
