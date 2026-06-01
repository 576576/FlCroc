import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

/// Cross-platform file drop target using the [desktop_drop] plugin.
///
/// On desktop, shows a hint overlay with [hintText] while files are dragged
/// over. On mobile, renders [child] directly.
class FileDropTarget extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final ValueChanged<List<File>> onFilesDropped;
  final ValueChanged<bool>? onHoverChanged;
  final String? hintText;

  const FileDropTarget({
    super.key,
    required this.child,
    this.enabled = true,
    required this.onFilesDropped,
    this.onHoverChanged,
    this.hintText,
  });

  @override
  State<FileDropTarget> createState() => _FileDropTargetState();
}

class _FileDropTargetState extends State<FileDropTarget> {
  bool _isOver = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final hint = widget.hintText ?? '';

    return DropTarget(
      onDragDone: (detail) {
        final files = detail.files
            .map((f) => File(f.path))
            .where((f) => f.existsSync())
            .toList();
        if (files.isNotEmpty) {
          widget.onFilesDropped(files);
        }
        _setHover(false);
      },
      onDragEntered: (_) => _setHover(true),
      onDragExited: (_) => _setHover(false),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            widget.child,
            if (_isOver)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.primary.withAlpha(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_upload, size: 48),
                        if (hint.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(hint, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _setHover(bool value) {
    if (_isOver != value) {
      _isOver = value;
      widget.onHoverChanged?.call(value);
    }
  }
}
