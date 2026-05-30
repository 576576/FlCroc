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

class _TransferStatsWidgetState extends ConsumerState<TransferStatsWidget>
    with SingleTickerProviderStateMixin {
  int _cycleIndex = 0; // 0=speed, 1=total size, 2=count+time
  late final _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final _pressAnim = Tween<double>(begin: 1, end: 0.96).animate(
    CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

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
    transfers
        .where((t) => t.endTime != null)
        .fold<int>(0, (a, t) => a + t.endTime!.difference(t.startTime).inSeconds);

    String primaryValue;

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

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        _cycle();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (_, child) => Transform.scale(scale: _pressAnim.value, child: child),
        child: CommonCard(
      info: Info(iconData: infoIcon, label: infoLabel),
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
          ],
        ),
      ),
      ),
    ),
    );
  }

}
