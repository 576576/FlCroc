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
      final libName = switch (Platform.operatingSystem) {
        'linux' => 'libcroc_bridge.so',
        'macos' => 'libcroc_bridge.dylib',
        'windows' => 'libcroc_bridge.dll',
        _ => 'libcroc_bridge.so',
      };
      // On Android, the .so is in jniLibs and loaded by name.
      // On desktop, try the executable directory first, then system paths.
      if (Platform.isAndroid) {
        return DynamicLibrary.open(libName);
      }
      // Desktop: look next to the executable
      final exeDir = Directory(Platform.resolvedExecutable).parent.path;
      final localPath = '$exeDir/$libName';
      if (File(localPath).existsSync()) {
        return DynamicLibrary.open(localPath);
      }
      // Fallback: look in lib/ subdirectory (Linux bundle convention)
      final libPath = '$exeDir/lib/$libName';
      if (File(libPath).existsSync()) {
        return DynamicLibrary.open(libPath);
      }
      return null;
    } catch (e) {
      commonPrint('Failed to load library: $e');
    }
    return null;
  }

  @override
  Future<String> getVersion() async {
    final lib = _lib;
    if (!_isAvailable || lib == null) return 'unknown';
    try {
      final func = lib.lookupFunction<
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
    final lib = _lib;
    if (!_isAvailable || lib == null) {
      yield const TransferProgress(
        transferId: '',
        status: TransferProgressStatus.failed,
        error: 'croc bridge not available',
      );
      return;
    }

    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    yield TransferProgress(
      transferId: transferId,
      status: TransferProgressStatus.initializing,
    );

    try {
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.connecting,
      );

      // Call CrocSendFiles
      final sendFunc = lib.lookupFunction<
          Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>)>('CrocSendFiles');

      final pathsJson = jsonEncode(options.filePaths);
      final optsJson = jsonEncode({
        'code_phrase': options.codePhrase ?? '',
        'curve': options.curve,
        'hash_algorithm': options.hashAlgorithm,
        'no_compress': options.noCompress,
        'overwrite': options.overwrite,
        'zip_folder': options.zipFolder,
        'git_ignore': options.gitIgnore,
        'only_local': options.onlyLocal,
        'disable_local': options.disableLocal,
        'relay_address': options.relayAddress ?? '',
        'relay_password': options.relayPassword ?? '',
        'exclude': options.exclude,
      });

      final pathsPtr = pathsJson.toNativeUtf8();
      final optsPtr = optsJson.toNativeUtf8();
      final resultPtr = sendFunc(pathsPtr, optsPtr);
      final resultJson = resultPtr.toDartString();

      malloc.free(pathsPtr);
      malloc.free(optsPtr);
      malloc.free(resultPtr);

      final result = jsonDecode(resultJson) as Map<String, dynamic>;
      if (result.containsKey('error')) {
        yield TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.failed,
          error: result['error'] as String?,
        );
        return;
      }

      final codePhrase = result['code_phrase'] as String?;
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.transferring,
        codePhrase: codePhrase,
      );

      // Poll progress until complete
      final pollFunc = lib.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('CrocPollProgress');

      while (true) {
        await Future.delayed(const Duration(milliseconds: 200));
        final pollPtr = pollFunc();
        final pollJson = pollPtr.toDartString();
        malloc.free(pollPtr);

        if (pollJson == 'null' || pollJson == '{}') continue;

        final event = jsonDecode(pollJson) as Map<String, dynamic>;
        final type = event['type'] as int? ?? 0;

        if (type == 2) {
          // complete
          yield TransferProgress(
            transferId: transferId,
            status: TransferProgressStatus.completed,
          );
          return;
        } else if (type == 3) {
          // error
          yield TransferProgress(
            transferId: transferId,
            status: TransferProgressStatus.failed,
            error: event['error'] as String?,
          );
          return;
        } else if (type == 1) {
          // progress
          yield TransferProgress(
            transferId: transferId,
            status: TransferProgressStatus.transferring,
            totalFiles: (event['total_files'] as int?) ?? 0,
            totalSize: (event['total_size'] as int?) ?? 0,
          );
        }
      }
    } catch (e) {
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.failed,
        error: e.toString(),
      );
    }
  }

  @override
  Stream<TransferProgress> receiveFiles(ReceiveOptions options) async* {
    final lib = _lib;
    if (!_isAvailable || lib == null) {
      yield const TransferProgress(
        transferId: '',
        status: TransferProgressStatus.failed,
        error: 'croc bridge not available',
      );
      return;
    }

    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    yield TransferProgress(
      transferId: transferId,
      status: TransferProgressStatus.initializing,
    );

    try {
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.connecting,
      );

      final recvFunc = lib.lookupFunction<
          Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>)>('CrocReceiveFiles');

      final optsJson = jsonEncode({
        'overwrite': options.overwrite,
        'only_local': options.onlyLocal,
        'output_path': options.outputPath,
        'relay_address': options.relayAddress ?? '',
        'relay_password': options.relayPassword ?? '',
      });

      final codePtr = options.codePhrase.toNativeUtf8();
      final optsPtr = optsJson.toNativeUtf8();
      final resultPtr = recvFunc(codePtr, optsPtr);
      final resultJson = resultPtr.toDartString();

      malloc.free(codePtr);
      malloc.free(optsPtr);
      malloc.free(resultPtr);

      final result = jsonDecode(resultJson) as Map<String, dynamic>;
      if (result.containsKey('error')) {
        yield TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.failed,
          error: result['error'] as String?,
        );
        return;
      }

      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.transferring,
      );

      // Poll progress
      final pollFunc = lib.lookupFunction<
          Pointer<Utf8> Function(),
          Pointer<Utf8> Function()>('CrocPollProgress');

      while (true) {
        await Future.delayed(const Duration(milliseconds: 200));
        final pollPtr = pollFunc();
        final pollJson = pollPtr.toDartString();
        malloc.free(pollPtr);

        if (pollJson == 'null' || pollJson == '{}') continue;

        final event = jsonDecode(pollJson) as Map<String, dynamic>;
        final type = event['type'] as int? ?? 0;

        if (type == 2) {
          yield TransferProgress(
            transferId: transferId,
            status: TransferProgressStatus.completed,
          );
          return;
        } else if (type == 3) {
          yield TransferProgress(
            transferId: transferId,
            status: TransferProgressStatus.failed,
            error: event['error'] as String?,
          );
          return;
        } else if (type == 1) {
          yield TransferProgress(
            transferId: transferId,
            status: TransferProgressStatus.transferring,
            totalFiles: (event['total_files'] as int?) ?? 0,
            totalSize: (event['total_size'] as int?) ?? 0,
          );
        }
      }
    } catch (e) {
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.failed,
        error: e.toString(),
      );
    }
  }

  @override
  Future<bool> cancelTransfer(String transferId) async {
    final lib = _lib;
    if (!_isAvailable || lib == null) return false;
    try {
      final func = lib.lookupFunction<
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

