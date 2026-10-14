import 'dart:io';

import 'package:fl_croc/common/common.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A widget that accepts files dragged from the shell onto it.
///
/// Only Windows has a native drop target (see `windows/runner/drop_target.cpp`);
/// elsewhere this is a pass-through and files have to be picked with the button.
///
/// The native target is registered on the whole Flutter view, so every instance
/// on screen receives every drag event and each one decides for itself whether
/// the cursor is over it.
class const FileDropTarget({
  super.key,
  required this.child,
  this.enabled = true,
  required this.onFilesDropped,
  this.onHoverChanged,
}) extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final ValueChanged<List<File>> onFilesDropped;
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<FileDropTarget> createState() => _FileDropTargetState();
}

class _FileDropTargetState() extends State<FileDropTarget> {
  bool _isOver = false;
  bool _listening = false;

  bool get _supported => widget.enabled && isWindows;

  @override
  void initState() {
    super.initState();
    _syncListener();
  }

  @override
  void didUpdateWidget(FileDropTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncListener();
  }

  @override
  void dispose() {
    if (_listening) {
      _DropChannel.instance.removeListener(_onDropEvent);
    }
    super.dispose();
  }

  void _syncListener() {
    if (_supported && !_listening) {
      _DropChannel.instance.addListener(_onDropEvent);
      _listening = true;
    } else if (!_supported && _listening) {
      _DropChannel.instance.removeListener(_onDropEvent);
      _listening = false;
      _setOver(false);
    }
  }

  void _onDropEvent(_DropEvent event) {
    if (!mounted) return;

    final renderObject = context.findRenderObject();
    final inside = renderObject is RenderBox && event.position != null
        ? _contains(renderObject, event.position!)
        : false;

    switch (event.kind) {
      case _DropKind.enter:
      case _DropKind.update:
        _setOver(inside);
      case _DropKind.exit:
        _setOver(false);
      case _DropKind.drop:
        _setOver(false);
        if (inside) _deliver(event.paths);
    }
  }

  /// The runner reports physical client pixels; [RenderBox.globalToLocal] works
  /// in logical ones.
  bool _contains(RenderBox box, Offset physicalPixels) {
    if (!box.hasSize) return false;
    final logical = physicalPixels / MediaQuery.devicePixelRatioOf(context);
    return box.paintBounds.contains(box.globalToLocal(logical));
  }

  void _deliver(List<String> paths) {
    final files = <File>[];
    for (final path in paths) {
      final file = File(path);
      if (file.existsSync()) {
        files.add(file);
      } else {
        commonPrint('drop target: file not found: $path');
      }
    }
    commonPrint(
      'drop target: delivered ${files.length} of ${paths.length} path(s)',
    );
    if (files.isNotEmpty) {
      widget.onFilesDropped(files);
    }
  }

  void _setOver(bool value) {
    if (_isOver == value || !mounted) return;
    setState(() => _isOver = value);
    widget.onHoverChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return widget.child;

    return Stack(
      children: [
        widget.child,
        if (_isOver)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
              ),
            ),
          ),
      ],
    );
  }
}

enum _DropKind() {
  enter,
  update,
  exit,
  drop,
}

/// One notification from the runner's drop target.
class const _DropEvent(this.kind, {this.position, this.paths = const []}) {
  final _DropKind kind;

  /// Cursor position in physical client pixels; null for [exit].
  final Offset? position;

  /// Dropped paths, relative to the machine — only set for [drop].
  final List<String> paths;
}

/// Receives drag-and-drop notifications from the Windows runner.
///
/// Channel name and method names are duplicated in `drop_target.cpp`; changing
/// one without the other silences drops with no error anywhere.
class _DropChannel._() {
  this {
    _channel.setMethodCallHandler(_handle);
  }

  static final _DropChannel instance = _DropChannel._();

  static const _channel = MethodChannel('fl_croc/drop');

  final List<void Function(_DropEvent)> _listeners = [];

  void addListener(void Function(_DropEvent) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(_DropEvent) listener) {
    _listeners.remove(listener);
  }

  Future<void> _handle(MethodCall call) async {
    switch (call.method) {
      case 'entered':
        _emit(_DropEvent(_DropKind.enter, position: _point(call.arguments)));
      case 'updated':
        _emit(_DropEvent(_DropKind.update, position: _point(call.arguments)));
      case 'exited':
        _emit(const _DropEvent(_DropKind.exit));
      case 'dropped':
        final payload = (call.arguments as Map).cast<String, Object?>();
        _emit(
          _DropEvent(
            _DropKind.drop,
            position: Offset(
              (payload['x'] as num).toDouble(),
              (payload['y'] as num).toDouble(),
            ),
            paths: (payload['paths'] as List).cast<String>(),
          ),
        );
      default:
        throw MissingPluginException('unknown drop event: ${call.method}');
    }
  }

  void _emit(_DropEvent event) {
    // Copy: a listener may unregister itself while handling the event.
    for (final listener in List.of(_listeners)) {
      listener(event);
    }
  }

  static Offset _point(Object? arguments) {
    final list = (arguments as List).cast<num>();
    return Offset(list[0].toDouble(), list[1].toDouble());
  }
}
