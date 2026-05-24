import 'dart:async';
import 'dart:io';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/interface.dart';
import 'package:fl_croc/core/lib.dart';
import 'package:fl_croc/core/service.dart';
import 'package:fl_croc/models/models.dart';

/// Core controller that manages the croc backend lifecycle.
///
/// **Backend priority:**
///   1. FFI  (`CoreLib`)   — Go shared library, best for Android
///   2. Process (`CoreService`) — bundled croc binary, desktop fallback
class CoreController {
  static CoreController? _instance;
  CoreInterface? _interface;

  CoreController._internal();

  factory CoreController() {
    _instance ??= CoreController._internal();
    return _instance!;
  }

  bool get isAvailable =>
      _interface?.isAvailable ?? false;

  bool get isCompleted => isAvailable;

  /// Initialize the best available backend.
  Future<bool> init() async {
    // 1) Try FFI shared library first (bundled .so / .dll / .dylib)
    final lib = CoreLib();
    if (await lib.init()) {
      _interface = lib;
      commonPrint('CoreController: using FFI backend');
      return true;
    }

    // 2) Fall back to bundled CLI binary
    final svc = CoreService();
    if (await svc.init()) {
      _interface = svc;
      commonPrint('CoreController: using process backend');
      return true;
    }

    commonPrint('CoreController: no backend available');
    return false;
  }

  Future<String> getVersion() async {
    if (_interface == null) return 'unavailable';
    return _interface!.getVersion();
  }

  Future<String> generateCodePhrase() async {
    if (_interface == null) {
      // Fallback random generator
      final rng = DateTime.now().microsecondsSinceEpoch;
      const adj = ['swift', 'bold', 'calm', 'keen', 'warm', 'cool'];
      const nouns = ['falcon', 'jaguar', 'python', 'raven', 'otter'];
      const verbs = ['dash', 'zoom', 'glide', 'soar', 'rush'];
      return '${adj[rng % adj.length]}-'
          '${nouns[(rng ~/ 2) % nouns.length]}-'
          '${verbs[(rng ~/ 3) % verbs.length]}';
    }
    return _interface!.generateCodePhrase();
  }

  Stream<TransferProgress> sendFiles(SendOptions options) {
    if (_interface == null) {
      return Stream.value(const TransferProgress(
        status: TransferProgressStatus.failed,
        error: 'No croc backend available',
      ));
    }
    return _interface!.sendFiles(options);
  }

  Stream<TransferProgress> receiveFiles(ReceiveOptions options) {
    if (_interface == null) {
      return Stream.value(const TransferProgress(
        status: TransferProgressStatus.failed,
        error: 'No croc backend available',
      ));
    }
    return _interface!.receiveFiles(options);
  }

  Future<bool> cancelTransfer(String transferId) async {
    if (_interface == null) return false;
    return _interface!.cancelTransfer(transferId);
  }

  Future<bool> shutdown() async {
    final ok = await _interface?.shutdown() ?? true;
    _interface = null;
    return ok;
  }
}

final coreController = CoreController();
