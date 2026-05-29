import 'dart:io';

import 'package:flutter/material.dart';

/// Cross-platform file drop target built on Flutter's native DragTarget.
///
/// Works on desktop (Windows/macOS/Linux) where Flutter's engine
/// forwards native OS file drops to DragTarget`<String>`.
/// On mobile, renders child directly (no drag support).
class FileDropTarget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final ValueChanged<List<File>> onFilesDropped;
  final ValueChanged<bool>? onHoverChanged;

  const FileDropTarget({
    super.key,
    required this.child,
    this.enabled = true,
    required this.onFilesDropped,
    this.onHoverChanged,
  });

  @override
  State<FileDropTarget> createState() => _FileDropTargetState();
}

class _FileDropTargetState extends State<FileDropTarget> {
  bool _isOver = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: _handleDrop,
      onLeave: (_) => _setHover(false),
      onMove: (_) => _setHover(true),
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        if (hovering != _isOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _setHover(hovering));
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (hovering)
              Container(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.cloud_upload, size: 48),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleDrop(DragTargetDetails<String> details) {
    _setHover(false);
    final path = details.data;
    final file = File(path);
    if (file.existsSync()) {
      widget.onFilesDropped([file]);
    }
  }

  void _setHover(bool value) {
    if (_isOver != value) {
      _isOver = value;
      widget.onHoverChanged?.call(value);
    }
  }
}
