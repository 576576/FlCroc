import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fl_croc/common/common.dart';
import 'package:flutter/material.dart';

/// Cross-platform file drop target using the [desktop_drop] plugin.
///
/// The [onHoverChanged] callback notifies the parent about drag-over state,
/// allowing custom visual feedback. The widget itself only applies a subtle
/// tint when files are dragged over.
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

    return DropTarget(
      onDragDone: (detail) {
        commonPrint('DropTarget onDragDone: ${detail.files.length} files, paths=${detail.files.map((f) => f.path).toList()}');
        final files = <File>[];
        for (final f in detail.files) {
          final file = File(f.path);
          if (file.existsSync()) {
            files.add(file);
          } else {
            commonPrint('DropTarget: file not found: ${f.path}');
          }
        }
        _setOver(false);
        if (files.isNotEmpty) {
          widget.onFilesDropped(files);
        }
      },
      onDragEntered: (_) => _setOver(true),
      onDragExited: (_) => _setOver(false),
      child: Stack(
        children: [
          widget.child,
          if (_isOver)
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
              ),
            ),
        ],
      ),
    );
  }

  void _setOver(bool value) {
    if (_isOver != value) {
      setState(() => _isOver = value);
      widget.onHoverChanged?.call(value);
    }
  }
}
