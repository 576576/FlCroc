import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
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
            onPressed: () {
              appController.clearHistory();
              context.showSnackBar(l10n.historyCleared);
            },
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
                final hasReceivedFile = !isSent &&
                    transfer.status == TransferStatus.completed &&
                    transfer.files.isNotEmpty &&
                    transfer.files.any((f) => f.path.isNotEmpty);
                return ListTile(
                  leading: Icon(
                    isSent ? Icons.upload : Icons.download,
                    color: _getIconColor(transfer, context),
                  ),
                  title: Text(
                    _formatTransferTitle(transfer),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${transfer.totalSize.fileSize} • ${transfer.startTime.timeAgoL10n(l10n)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasReceivedFile)
                        IconButton(
                          icon: const Icon(Icons.folder_open, size: 18),
                          tooltip: l10n.openFolder,
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final f = transfer.files.firstWhere((f) => f.path.isNotEmpty);
                            globalState.openFolder(f.path);
                          },
                        ),
                      _buildStatusChip(transfer.status, context),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// Format transfer title: for text, show first 50 chars; for files, show file names.
  String _formatTransferTitle(TransferRecord t) {
    final names = t.files.map((f) => f.name);
    final joined = names.join(', ');
    // If it's a text transfer (single file with no extension and path empty), truncate
    if (t.files.length == 1 && !t.files.first.name.contains('.') && t.files.first.path.isEmpty) {
      return joined.length > 50 ? '${joined.substring(0, 50)}…' : joined;
    }
    return joined;
  }

  /// Icon color: text → primary, file → green, failed → red.
  Color _getIconColor(TransferRecord t, BuildContext context) {
    if (t.status == TransferStatus.failed) return Colors.red;
    return _isTextTransfer(t) ? context.colorScheme.primary : Colors.green;
  }

  bool _isTextTransfer(TransferRecord t) {
    return t.files.length == 1 &&
        !t.files.first.name.contains('.') &&
        t.files.first.path.isEmpty;
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
        color = context.colorScheme.onSurfaceVariant;
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
