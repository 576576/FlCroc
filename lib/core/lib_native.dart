import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/interface.dart';
import 'package:fl_croc/models/models.dart';

/// FFI binding for the Go croc bridge shared library.
///
/// Uses the vendored croc at `submodules/croc/` via the Go bridge in `go_bridge/`.
class CoreLib extends CoreInterface {
  static CoreLib? _instance;
  DynamicLibrary? _lib;
  bool _isAvailable = false;

  /// Built-in croc version (synced with submodules/croc vendored source).
  static const builtinCrocVersion = '10.4.4';

  // Cached FFI function for freeing Go-allocated strings
  void Function(Pointer<Utf8>)? _freeGoString;

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
      // Cache the free function
      _freeGoString = _lib!.lookupFunction<
          Void Function(Pointer<Utf8>),
          void Function(Pointer<Utf8>)>('CrocFreeString');
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
    // Try FFI first (live croc submodule version).
    try {
      final lib = _lib;
      if (lib != null) {
        final func = lib.lookupFunction<
            Pointer<Utf8> Function(),
            Pointer<Utf8> Function()>('CrocGetVersion');
        final ptr = func();
        final ver = ptr.toDartString();
        _freeGoString?.call(ptr);
        if (ver.isNotEmpty) return _stripCrocPrefix(ver);
      }
    } catch (_) {}
    throw UnsupportedError('unavailable');
  }

  String _stripCrocPrefix(String raw) {
    return raw.replaceAll(RegExp(r'^croc\s*v?'), '');
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
      final opts = <String, dynamic>{};
      if (options.codePhrase != null && options.codePhrase!.isNotEmpty) {
        opts['code_phrase'] = options.codePhrase;
      }
      if (options.sendingText) {
        opts['sending_text'] = true;
        opts['text_content'] = options.textContent;
      }
      if (options.curve != 'p256') opts['curve'] = options.curve;
      if (options.hashAlgorithm != 'xxhash') opts['hash_algorithm'] = options.hashAlgorithm;
      if (options.noCompress) opts['no_compress'] = true;
      if (options.overwrite) opts['overwrite'] = true;
      if (options.zipFolder) opts['zip_folder'] = true;
      if (options.gitIgnore) opts['git_ignore'] = true;
      if (options.onlyLocal) opts['only_local'] = true;
      if (options.disableLocal) opts['disable_local'] = true;
      if (options.relayAddress != null && options.relayAddress!.isNotEmpty) {
        opts['relay_address'] = options.relayAddress;
      }
      if (options.relayAddress6 != null && options.relayAddress6!.isNotEmpty) {
        opts['relay_address6'] = options.relayAddress6;
      }
      if (options.relayPassword != null && options.relayPassword!.isNotEmpty) {
        opts['relay_password'] = options.relayPassword;
      }
      if (options.relayPorts != null && options.relayPorts!.isNotEmpty) {
        opts['relay_ports'] = options.relayPorts;
      }
      if (options.exclude.isNotEmpty) opts['exclude'] = options.exclude;
      final optsJson = jsonEncode(opts);

      final pathsPtr = pathsJson.toNativeUtf8();
      final optsPtr = optsJson.toNativeUtf8();
      final resultPtr = sendFunc(pathsPtr, optsPtr);
      final resultJson = resultPtr.toDartString();

      malloc.free(pathsPtr);  // Dart-allocated
      malloc.free(optsPtr);   // Dart-allocated
      _freeGoString?.call(resultPtr);  // Go-allocated

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
        try {
          final pollPtr = pollFunc();
          final pollJson = pollPtr.toDartString();
          _freeGoString?.call(pollPtr);

          if (pollJson == 'null' || pollJson == '{}') continue;
          if (pollJson.length < 5) continue; // too short to be valid JSON

          final event = jsonDecode(pollJson) as Map<String, dynamic>;
          final type = event['type'] as int? ?? 0;

          if (type == 2) {
            yield TransferProgress(
              transferId: transferId,
              status: TransferProgressStatus.completed,
              totalFiles: (event['total_files'] as int?) ?? 0,
              totalSize: (event['total_size'] as int?) ?? 0,
              currentFile: event['current_file'] as String? ?? '',
              isText: event['is_text'] as bool? ?? false,
              textContent: event['text_content'] as String? ?? '',
            );
            return;
          } else if (type == 3) {
            yield TransferProgress(
              transferId: transferId,
              status: TransferProgressStatus.failed,
              error: event['error'] as String?,
            );
            return;
          } else if (type == 1 || type == 4) {
            yield TransferProgress(
              transferId: transferId,
              status: TransferProgressStatus.transferring,
              totalFiles: (event['total_files'] as int?) ?? 0,
              totalSize: (event['total_size'] as int?) ?? 0,
              transferredSize: (event['transferred_size'] as int?) ?? 0,
              codePhrase: event['code_phrase'] as String?,
            );
          }
        } catch (_) {
          // Ignore malformed poll events; keep polling
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

      final opts = <String, dynamic>{};
      if (options.curve != 'p256') opts['curve'] = options.curve;
      if (options.overwrite) opts['overwrite'] = true;
      if (options.onlyLocal) opts['only_local'] = true;
      if (options.outputPath.isNotEmpty) opts['output_path'] = options.outputPath;
      if (options.relayAddress != null && options.relayAddress!.isNotEmpty) {
        opts['relay_address'] = options.relayAddress;
      }
      if (options.relayAddress6 != null && options.relayAddress6!.isNotEmpty) {
        opts['relay_address6'] = options.relayAddress6;
      }
      if (options.relayPassword != null && options.relayPassword!.isNotEmpty) {
        opts['relay_password'] = options.relayPassword;
      }
      if (options.relayPorts != null && options.relayPorts!.isNotEmpty) {
        opts['relay_ports'] = options.relayPorts;
      }
      // Always include hash_algorithm so receiver matches sender's hash
      opts['hash_algorithm'] = 'xxhash';
      final optsJson = jsonEncode(opts);

      final codePtr = options.codePhrase.toNativeUtf8();
      final optsPtr = optsJson.toNativeUtf8();
      final resultPtr = recvFunc(codePtr, optsPtr);
      final resultJson = resultPtr.toDartString();

      malloc.free(codePtr);  // Dart-allocated
      malloc.free(optsPtr);   // Dart-allocated
      _freeGoString?.call(resultPtr);  // Go-allocated

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
        try {
          final pollPtr = pollFunc();
          final pollJson = pollPtr.toDartString();
          _freeGoString?.call(pollPtr);

          if (pollJson == 'null' || pollJson == '{}') continue;
          if (pollJson.length < 5) continue;

          final event = jsonDecode(pollJson) as Map<String, dynamic>;
          final type = event['type'] as int? ?? 0;

          if (type == 2) {
            if (event['transfer_id'] != 'closed') {
              yield TransferProgress(
                transferId: transferId,
                status: TransferProgressStatus.completed,
                totalFiles: (event['total_files'] as int?) ?? 0,
                totalSize: (event['total_size'] as int?) ?? 0,
                currentFile: event['current_file'] as String? ?? '',
                isText: event['is_text'] as bool? ?? false,
                textContent: event['text_content'] as String? ?? '',
              );
            }
            return;
          } else if (type == 3) {
            yield TransferProgress(
              transferId: transferId,
              status: TransferProgressStatus.failed,
              error: event['error'] as String?,
            );
            return;
          } else if (type == 1 || type == 4) {
            yield TransferProgress(
              transferId: transferId,
              status: TransferProgressStatus.transferring,
              totalFiles: (event['total_files'] as int?) ?? 0,
              totalSize: (event['total_size'] as int?) ?? 0,
              transferredSize: (event['transferred_size'] as int?) ?? 0,
            );
          }
        } catch (_) {
          // Ignore malformed poll events
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

