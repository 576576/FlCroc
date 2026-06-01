import 'dart:developer' as dev;

/// Simple in-memory log buffer for the debug log viewer.
class LogBuffer {
  static final List<String> _logs = [];
  static const _maxLines = 500;

  /// Whether debug mode is active (set by settings page).
  static bool debugMode = false;

  static List<String> get logs => List.unmodifiable(_logs);

  static void add(String message) {
    _logs.add(message);
    if (_logs.length > _maxLines) _logs.removeAt(0);
  }

  static void clear() => _logs.clear();
}

void commonPrint(String message) {
  dev.log(message, name: 'FlCroc');
  LogBuffer.add(message);
}

extension PrintExt on String {
  void get log => commonPrint(this);
}
