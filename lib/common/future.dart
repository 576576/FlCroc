import 'dart:async';

import 'package:fl_croc/common/function.dart';

extension FutureExt<T> on Future<T> {
  Future<T> withTimeout({
    required Duration duration,
    String? message,
  }) {
    return timeout(duration, onTimeout: () {
      throw TimeoutException(message ?? 'Operation timed out');
    });
  }
}
