import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

/// Cross-platform file drop target using Flutter's native DragTarget.
///
/// On desktop (Windows/macOS/Linux), Flutter's engine forwards
/// native OS file drops as [DragTarget]<String> events.
/// Multiple files dropped simultaneously are collected and
/// dispatched as a batch via [onFilesDropped].
/// On mobile, renders [child] directly.
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
  final List<File> _pendingFiles = [];
  Timer? _batchTimer;

  @override
  void dispose() {
    _batchTimer?.cancel();
    _flushPendingFiles();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return DragTarget<String>(
      onWillAcceptWithDetails: (_) {
        _setHover(true);
        return true;
      },
      onAcceptWithDetails: _handleDrop,
      onLeave: (_) => _setHover(false),
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
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
    final path = details.data;
    final file = File(path);
    if (file.existsSync()) {
      _pendingFiles.add(file);
      // Debounce: collect files for 100ms then dispatch batch
      _batchTimer?.cancel();
      _batchTimer = Timer(const Duration(milliseconds: 100), _flushPendingFiles);
    }
  }

  void _flushPendingFiles() {
    if (_pendingFiles.isNotEmpty) {
      final files = List<File>.from(_pendingFiles);
      _pendingFiles.clear();
      widget.onFilesDropped(files);
    }
    _setHover(false);
  }

  void _setHover(bool value) {
    if (_isOver != value) {
      _isOver = value;
      widget.onHoverChanged?.call(value);
    }
  }
}
