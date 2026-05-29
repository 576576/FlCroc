import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Combined transfer statistics card.
/// Tap to cycle: current speed → total transferred → transfer count + total time.
class TransferStatsWidget extends ConsumerStatefulWidget {
  const TransferStatsWidget({super.key});

  @override
  ConsumerState<TransferStatsWidget> createState() => _TransferStatsWidgetState();
}

class _TransferStatsWidgetState extends ConsumerState<TransferStatsWidget> {
  int _cycleIndex = 0; // 0=speed, 1=total size, 2=count+time

  void _cycle() => setState(() => _cycleIndex = (_cycleIndex + 1) % 3);

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final speeds = ref.watch(appStateProvider).speeds;
    final transfers = ref.watch(transfersProvider);

    final totalSpeed = speeds.values.fold<double>(0, (a, b) => a + b);
    final totalSize = transfers.fold<int>(0, (a, t) => a + t.totalSize);
    final transferCount = transfers.length;

    // Total elapsed time across all completed transfers
    final totalSeconds = transfers
        .where((t) => t.endTime != null)
        .fold<int>(0, (a, t) => a + t.endTime!.difference(t.startTime).inSeconds);
    final totalTimeStr = totalSeconds > 0
        ? _formatTime(totalSeconds)
        : '--';

    String primaryValue;
    String? secondaryLabel;

    switch (_cycleIndex) {
      case 0:
        primaryValue = totalSpeed.transferSpeed;
        break;
      case 1:
        primaryValue = totalSize.fileSize;
        break;
      default:
        primaryValue = '$transferCount';
        break;
    }

    final infoLabel = switch (_cycleIndex) {
      0 => l10n.transferSpeed,
      1 => l10n.totalTransferred,
      _ => l10n.transfersUnit,
    };
    final infoIcon = switch (_cycleIndex) {
      0 => Icons.speed,
      1 => Icons.data_usage,
      _ => Icons.repeat,
    };

    return CommonCard(
      info: Info(iconData: infoIcon, label: infoLabel),
      child: GestureDetector(
        onTap: _cycle,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryValue,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  secondaryLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
