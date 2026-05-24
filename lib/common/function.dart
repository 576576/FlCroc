import 'dart:async';

import 'package:fl_croc/enum/enum.dart';

class Debouncer {
  final Map<FunctionTag, Timer?> _operations = {};

  void call(FunctionTag tag, VoidCallback callback, {Duration? duration}) {
    _operations[tag]?.cancel();
    _operations[tag] = Timer(duration ?? const Duration(milliseconds: 200), () {
      callback();
      _operations[tag] = null;
    });
  }

  void cancel(FunctionTag tag) {
    _operations[tag]?.cancel();
    _operations[tag] = null;
  }

  void dispose() {
    for (final timer in _operations.values) {
      timer?.cancel();
    }
    _operations.clear();
  }
}

typedef VoidCallback = void Function();
