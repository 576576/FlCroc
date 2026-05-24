import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/interface.dart';
import 'package:fl_croc/models/models.dart';

/// FFI binding for the Go croc bridge shared library.
/// Used primarily on Android where process spawning is limited.
///
/// On desktop platforms, CoreService (process-based) is preferred.
class CoreLib extends CoreInterface {
  static CoreLib? _instance;
  DynamicLibrary? _lib;
  bool _isAvailable = false;

  CoreLib._internal();

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> init() async {
    try {
      _lib = _loadLibrary();
      if (_lib == null) return false;
      _isAvailable = true;
      return true;
    } catch (e) {
      commonPrint('Failed to load croc bridge: $e');
      return false;
    }
  }

  DynamicLibrary? _loadLibrary() {
    try {
      if (Platform.isAndroid) {
        return DynamicLibrary.open('libcroc_bridge.so');
      } else if (Platform.isLinux) {
        return DynamicLibrary.open('libcroc_bridge.so');
      } else if (Platform.isMacOS) {
        return DynamicLibrary.open('libcroc_bridge.dylib');
      } else if (Platform.isWindows) {
        return DynamicLibrary.open('libcroc_bridge.dll');
      }
    } catch (e) {
      commonPrint('Failed to load library: $e');
    }
    return null;
  }

  @override
  Future<String> getVersion() async {
    if (!_isAvailable || _lib == null) return 'unknown';
    try {
      final func = _lib!.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('CrocGetVersion');
      final ptr = func();
      final version = ptr.toDartString();
      malloc.free(ptr);
      return version;
    } catch (e) {
      return 'error: $e';
    }
  }

  @override
  Future<String> generateCodePhrase() async {
    final rng = DateTime.now().microsecondsSinceEpoch;
    const adjectives = ['swift', 'bold', 'calm', 'keen', 'warm', 'cool'];
    const nouns = ['falcon', 'jaguar', 'python', 'raven', 'otter'];
    const verbs = ['dash', 'zoom', 'glide', 'soar', 'rush'];
    return '${adjectives[rng % adjectives.length]}-'
        '${nouns[(rng ~/ 2) % nouns.length]}-'
        '${verbs[(rng ~/ 3) % verbs.length]}';
  }

  @override
  Stream<TransferProgress> sendFiles(SendOptions options) async* {
    if (!_isAvailable) {
      yield const TransferProgress(
        transferId: '',
        status: TransferProgressStatus.failed,
        error: 'croc bridge not available',
      );
      return;
    }

    yield const TransferProgress(
      transferId: '',
      status: TransferProgressStatus.initializing,
    );

    try {
      yield const TransferProgress(
        transferId: '',
        status: TransferProgressStatus.connecting,
      );

      // When the Go bridge is built and loaded, use FFI to call CrocSendFiles
      // For now, yield placeholder
      yield const TransferProgress(
        transferId: 'ffi-pending',
        status: TransferProgressStatus.transferring,
      );
    } catch (e) {
      yield TransferProgress(
        transferId: '',
        status: TransferProgressStatus.failed,
        error: e.toString(),
      );
    }
  }

  @override
  Stream<TransferProgress> receiveFiles(ReceiveOptions options) async* {
    if (!_isAvailable) {
      yield const TransferProgress(
        transferId: '',
        status: TransferProgressStatus.failed,
        error: 'croc bridge not available',
      );
      return;
    }

    yield const TransferProgress(
      transferId: '',
      status: TransferProgressStatus.initializing,
    );

    try {
      yield const TransferProgress(
        transferId: '',
        status: TransferProgressStatus.connecting,
      );

      yield const TransferProgress(
        transferId: 'ffi-pending',
        status: TransferProgressStatus.transferring,
      );
    } catch (e) {
      yield TransferProgress(
        transferId: '',
        status: TransferProgressStatus.failed,
        error: e.toString(),
      );
    }
  }

  @override
  Future<bool> cancelTransfer(String transferId) async {
    if (!_isAvailable || _lib == null) return false;
    try {
      final func = _lib!.lookupFunction<
          Int32 Function(Pointer<Utf8>),
          int Function(Pointer<Utf8>)>('CrocCancelTransfer');
      final ptr = transferId.toNativeUtf8();
      final result = func(ptr);
      malloc.free(ptr);
      return result == 1;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> shutdown() async {
    _lib = null;
    _isAvailable = false;
    return true;
  }
}

