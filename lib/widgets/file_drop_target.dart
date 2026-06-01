import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fl_croc/common/common.dart';
import 'package:flutter/material.dart';

/// Cross-platform file drop target using the [desktop_drop] plugin.
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
        if (files.isNotEmpty) {
          widget.onFilesDropped(files);
        }
        setState(() => _isOver = false);
      },
      onDragEntered: (_) => setState(() => _isOver = true),
      onDragExited: (_) => setState(() => _isOver = false),
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
    );
  }
}
