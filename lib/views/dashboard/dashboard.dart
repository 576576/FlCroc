import 'dart:math';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/widgets.dart';

/// Shared notifier so that only one card at a time can be dragged.
final _dragIndexNotifier = ValueNotifier<int?>(null);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with TickerProviderStateMixin {
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _currentWidgetsNotifier = ValueNotifier<List<DashboardWidget>>([]);

  // ── Shake controller (parent-owned, FlClash pattern) ──
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingProvider);
    _currentWidgetsNotifier.value = List.from(settings.dashboardWidgets);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _shakeAnim = Tween<double>(begin: -0.012, end: 0.012).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _isEditNotifier.dispose();
    _currentWidgetsNotifier.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    final wasEdit = _isEditNotifier.value;
    _isEditNotifier.value = !wasEdit;

    if (!wasEdit) {
      // Entering edit mode → start shake
      _shakeCtrl.repeat(reverse: true);
    } else {
      // Exiting edit mode → stop shake, save
      _shakeCtrl.stop();
      _shakeCtrl.value = 0;
      ref.read(appSettingProvider.notifier).update(
            (s) => s.copyWith(
                dashboardWidgets: List.from(_currentWidgetsNotifier.value)),
          );
    }
  }

  void _removeWidget(int index) {
    final updated = List<DashboardWidget>.from(_currentWidgetsNotifier.value);
    updated.removeAt(index);
    _currentWidgetsNotifier.value = updated;
  }

  void _moveWidget(int oldIndex, int newIndex) {
    final updated = List<DashboardWidget>.from(_currentWidgetsNotifier.value);
    if (newIndex > oldIndex) newIndex--;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    _currentWidgetsNotifier.value = updated;
  }

  Map<DashboardWidget, Widget> _widgetBuilders() {
    return {
      DashboardWidget.transferStats: const TransferStatsWidget(),
      DashboardWidget.quickSend: const QuickSendWidget(),
      DashboardWidget.quickReceive: const QuickReceiveWidget(),
      DashboardWidget.recentTransfers: const RecentTransfersWidget(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final builders = _widgetBuilders();
    final l10n = context.appLocalizations;

    return CommonScaffold(
      title: l10n.dashboard,
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: _isEditNotifier,
          builder: (_, isEdit, _) => IconButton(
            onPressed: _toggleEdit,
            icon: Icon(isEdit ? Icons.check : Icons.edit_outlined),
            tooltip: isEdit ? l10n.done : l10n.edit,
          ),
        ),
      ],
      body: ValueListenableBuilder<List<DashboardWidget>>(
        valueListenable: _currentWidgetsNotifier,
        builder: (_, widgets, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isEditNotifier,
            builder: (_, isEdit, _) {
              return LayoutBuilder(builder: (context, constraints) {
                final availableWidth = constraints.maxWidth - 32;
                final columns = availableWidth < 400
                    ? 1
                    : availableWidth < 700
                        ? 2
                        : 3;
                final cardWidth =
                    (availableWidth - (columns - 1) * 8) / columns;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(widgets.length, (index) {
                          final w = widgets[index];
                          final child =
                              builders[w] ?? const SizedBox.shrink();
                          return SizedBox(
                            width: cardWidth,
                            child: _DashboardCard(
                              key: ValueKey(w),
                              widgetType: w,
                              isEdit: isEdit,
                              index: index,
                              shakeAnim: _shakeAnim,
                              onDelete: () => _removeWidget(index),
                              onMove: (oldIdx, newIdx) =>
                                  _moveWidget(oldIdx, newIdx),
                              child: child,
                            ),
                          );
                        }),
                      ),
                      if (isEdit) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.availableWidgets,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: DashboardWidget.values
                              .where((w) => !widgets.contains(w))
                              .map((w) {
                            return ActionChip(
                              avatar: const Icon(Icons.add, size: 18),
                              label: Text(l10n.dashboardWidgetName(w)),
                              onPressed: () {
                                final updated = List<DashboardWidget>.from(
                                    _currentWidgetsNotifier.value);
                                updated.add(w);
                                _currentWidgetsNotifier.value = updated;
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              });
            },
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// _DashboardCard — drag-reorder + delete (shake from parent)
// ────────────────────────────────────────────────────────────
//  FlClash architecture:
//    • Parent (_DashboardViewState)  owns shake  (_shakeCtrl)
//    • Child  (_DashboardCardState)  owns delete (_deleteCtrl only)

class _DashboardCard extends StatefulWidget {
  final DashboardWidget widgetType;
  final bool isEdit;
  final int index;
  final Animation<double> shakeAnim;
  final VoidCallback onDelete;
  final void Function(int oldIndex, int newIndex) onMove;
  final Widget child;

  const _DashboardCard({
    super.key,
    required this.widgetType,
    required this.isEdit,
    required this.index,
    required this.shakeAnim,
    required this.onDelete,
    required this.onMove,
    required this.child,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard>
    with SingleTickerProviderStateMixin {
  // ── Only ONE controller: delete animation (FlClash pattern) ──
  late AnimationController _deleteCtrl;
  late Animation<double> _deleteScale;
  late Animation<double> _deleteFade;
  bool _isDeletePending = false;
  final _shakeRandom = 0.7 + Random().nextDouble() * 0.3;

  @override
  void initState() {
    super.initState();
    _deleteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _deleteScale = Tween(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _deleteCtrl, curve: Curves.easeIn),
    );
    _deleteFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _deleteCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant _DashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEdit && oldWidget.isEdit) {
      // Exited edit mode → reset delete state
      _deleteCtrl.value = 0;
      _isDeletePending = false;
    }
  }

  @override
  void dispose() {
    _deleteCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeletePending = true);
    await _deleteCtrl.forward(from: 0);
    widget.onDelete();
  }

  /// Build the content with shake (from parent) and delete animations.
  Widget _buildAnimatedContent() {
    return AnimatedBuilder(
      animation: widget.shakeAnim,
      builder: (_, child) {
        final angle = (widget.isEdit && !_isDeletePending)
            ? widget.shakeAnim.value * _shakeRandom
            : 0.0;
        return Transform.rotate(angle: angle, child: child!);
      },
      child: AnimatedBuilder(
        animation: _deleteCtrl.view,
        builder: (_, child) {
          return Transform.scale(
            scale: _deleteScale.value,
            child: Opacity(opacity: _deleteFade.value, child: child!),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            // Delete button (only in edit mode, before delete starts)
            if (widget.isEdit && !_isDeletePending)
              Positioned(
                top: -8,
                right: -8,
                child: Material(
                  elevation: 2,
                  shape: const CircleBorder(),
                  color: context.colorScheme.error,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _handleDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEdit) {
      return _buildAnimatedContent();
    }

    // Edit mode: draggable
    return DragTarget<DashboardWidget>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final fromIndex = _dragIndexNotifier.value;
        if (fromIndex != null && fromIndex != widget.index) {
          widget.onMove(fromIndex, widget.index);
        }
      },
      builder: (_, candidateData, _) {
        final isHovering = candidateData.isNotEmpty;
        return LongPressDraggable<DashboardWidget>(
          data: widget.widgetType,
          delay: const Duration(milliseconds: 200),
          onDragStarted: () => _dragIndexNotifier.value = widget.index,
          onDragEnd: (_) => _dragIndexNotifier.value = null,
          feedback: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: widget.child,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: widget.child,
          ),
          child: AnimatedOpacity(
            opacity: isHovering ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: _buildAnimatedContent(),
          ),
        );
      },
    );
  }
}
