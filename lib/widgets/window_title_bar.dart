import 'package:fl_croc/common/common.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// FlClash-style custom Windows title bar.
/// 4 equal buttons on the right: pin, minimize, maximize, close.
/// The rest of the bar is a drag area via windowManager.startDragging().
const double _kHeaderHeight = 40;

class WindowTitleBar extends StatefulWidget {
  const WindowTitleBar({super.key});

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> with WindowListener {
  final _isMaximizedNotifier = ValueNotifier<bool>(false);
  final _isPinnedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _isMaximizedNotifier.dispose();
    _isPinnedNotifier.dispose();
    super.dispose();
  }

  Future<void> _initState() async {
    try {
      _isMaximizedNotifier.value = await windowManager.isMaximized();
      _isPinnedNotifier.value = await windowManager.isAlwaysOnTop();
    } catch (_) {}
  }

  Future<void> _toggleMaximize() async {
    try {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (_) {}
  }

  Future<void> _togglePin() async {
    try {
      final isPinned = await windowManager.isAlwaysOnTop();
      await windowManager.setAlwaysOnTop(!isPinned);
      _isPinnedNotifier.value = !isPinned;
    } catch (_) {}
  }

  @override
  void onWindowMaximize() => _isMaximizedNotifier.value = true;
  @override
  void onWindowUnmaximize() => _isMaximizedNotifier.value = false;

  @override
  Widget build(BuildContext context) {
    if (!isWindows && !isLinux) return const SizedBox.shrink();

    return SizedBox(
      height: _kHeaderHeight,
      child: Stack(
        children: [
          // Full-width drag area
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              onDoubleTap: _toggleMaximize,
              child: Container(color: context.colorScheme.primary.withAlpha(15)),
            ),
          ),
          // Window control buttons (right)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final iconColor = context.colorScheme.onSurface.withValues(alpha: 0.7);
    return Row(
      children: [
        IconButton(
          onPressed: _togglePin,
          icon: ValueListenableBuilder(
            valueListenable: _isPinnedNotifier,
            builder: (_, isPinned, c) {
              return Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 18,
              );
            },
          ),
          splashRadius: 14,
          visualDensity: VisualDensity.compact,
          color: iconColor,
        ),
        IconButton(
          onPressed: () => windowManager.minimize(),
          icon: const Icon(Icons.remove, size: 18),
          splashRadius: 14,
          visualDensity: VisualDensity.compact,
          color: iconColor,
        ),
        IconButton(
          onPressed: _toggleMaximize,
          icon: ValueListenableBuilder(
            valueListenable: _isMaximizedNotifier,
            builder: (_, isMaximized, c) {
              return Icon(
                isMaximized ? Icons.filter_none : Icons.crop_square,
                size: 18,
              );
            },
          ),
          splashRadius: 14,
          visualDensity: VisualDensity.compact,
          color: iconColor,
        ),
        IconButton(
          onPressed: () => windowManager.close(),
          icon: const Icon(Icons.close, size: 18),
          splashRadius: 14,
          visualDensity: VisualDensity.compact,
          color: iconColor,
        ),
      ],
    );
  }
}



