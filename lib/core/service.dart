import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/interface.dart';
import 'package:fl_croc/models/models.dart';
import 'package:path/path.dart' as p;

/// Core implementation using a bundled croc binary.
///
/// Binary search order:
///   1. `{appDir}/croc{exe}`       — alongside the Flutter executable (desktop)
///   2. `{appDir}/lib/croc{exe}`    — bundled lib dir
///   3. `{dataDir}/croc{exe}`       — extracted from assets (Android)
///   4. `croc` in system PATH       — development convenience
class CoreService extends CoreInterface {
  Process? _process;
  bool _isAvailable = false;
  String? _crocPath;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> init() async {
    _crocPath = await _findCrocBinary();
    if (_crocPath == null) {
      commonPrint('CoreService: croc binary not found');
      return false;
    }

    // Make sure it's executable
    try {
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', _crocPath!]);
      }
    } catch (_) {}

    try {
      final result = await Process.run(
        _crocPath!,
        ['--version'],
        environment: {'CROC_SECRET': ''},
      );
      if (result.exitCode == 0) {
        _isAvailable = true;
        commonPrint('CoreService: croc ready — ${result.stdout.toString().trim()}');
        return true;
      }
      commonPrint('CoreService: croc --version failed (exit ${result.exitCode})');
    } catch (e) {
      commonPrint('CoreService: croc launch failed — $e');
    }
    return false;
  }

  /// Search for croc binary in multiple locations.
  Future<String?> _findCrocBinary() async {
    final binaryName = Platform.isWindows ? 'croc.exe' : 'croc';

    // 1) App bundle directory (desktop: next to the exe)
    final appDir = p.dirname(Platform.resolvedExecutable);
    final paths = <String>[
      p.join(appDir, binaryName),
      p.join(appDir, 'lib', binaryName),
      p.join(appDir, 'data', binaryName),
    ];

    // 2) Flutter assets / data directory (Android)
    try {
      final dataDir = await _getDataDir();
      if (dataDir != null) {
        paths.add(p.join(dataDir, binaryName));
      }
    } catch (_) {}

    // 3) Current working directory (development)
    paths.add(p.join(Directory.current.path, binaryName));
    paths.add(p.join(Directory.current.path, 'build', binaryName));

    for (final path in paths) {
      if (File(path).existsSync()) {
        commonPrint('CoreService: found croc at $path');
        return path;
      }
    }

    // 4) System PATH
    try {
      final which = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(which, [binaryName]);
      if (result.exitCode == 0) {
        final found = result.stdout.toString().trim().split('\n').first;
        if (found.isNotEmpty) {
          commonPrint('CoreService: found croc in PATH: $found');
          return found;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<String?> _getDataDir() async {
    try {
      // Use path_provider if available
      final dir = await _getAppSupportDir();
      if (dir != null) return dir;
    } catch (_) {}
    return null;
  }

  Future<String?> _getAppSupportDir() async {
    try {
      if (Platform.isAndroid) {
        return '/data/data/com.flcroc.app/files';
      }
      if (Platform.isIOS) {
        final home = Platform.environment['HOME'] ?? '';
        return p.join(home, 'Library', 'Application Support');
      }
      if (Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? '';
        final xdg = Platform.environment['XDG_DATA_HOME'] ?? p.join(home, '.local', 'share');
        return p.join(xdg, 'flcroc');
      }
      if (Platform.isMacOS) {
        final home = Platform.environment['HOME'] ?? '';
        return p.join(home, 'Library', 'Application Support', 'FlCroc');
      }
      if (Platform.isWindows) {
        final appData = Platform.environment['APPDATA'] ?? '';
        return p.join(appData, 'FlCroc');
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<String> getVersion() async {
    if (_crocPath == null) return 'unknown';
    try {
      final result = await Process.run(_crocPath!, ['--version']);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'error: $e';
    }
  }

  @override
  Future<String> generateCodePhrase() async {
    final rng = DateTime.now().microsecondsSinceEpoch;
    const adj = ['swift', 'bold', 'calm', 'keen', 'warm', 'cool'];
    const nouns = ['falcon', 'jaguar', 'python', 'raven', 'otter'];
    const verbs = ['dash', 'zoom', 'glide', 'soar', 'rush'];
    return '${adj[rng % adj.length]}-'
        '${nouns[(rng ~/ 2) % nouns.length]}-'
        '${verbs[(rng ~/ 3) % verbs.length]}';
  }

  @override
  Stream<TransferProgress> sendFiles(SendOptions options) async* {
    if (_crocPath == null || !_isAvailable) {
      yield const TransferProgress(
        status: TransferProgressStatus.failed,
        error: 'croc binary not available. Run `flutter_croc_setup` to download.',
      );
      return;
    }

    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    yield TransferProgress(
      transferId: transferId,
      status: TransferProgressStatus.initializing,
    );

    final code = options.codePhrase ?? await generateCodePhrase();

    try {
      final args = <String>[
        'send',
        ...options.filePaths,
        '--code', code,
        '--curve', options.curve,
        '--hash', options.hashAlgorithm,
        if (options.noCompress) '--no-compress',
        if (options.overwrite) '--overwrite',
        if (options.zipFolder) '--zip',
        if (options.onlyLocal) '--local',
        if (options.disableLocal) '--no-local',
        if (options.socks5Proxy.isNotEmpty) '--socks5', options.socks5Proxy,
        if (options.relayAddress != null && options.relayAddress!.isNotEmpty)
          '--relay', options.relayAddress!,
        if (options.relayPassword != null && options.relayPassword!.isNotEmpty)
          '--pass', options.relayPassword!,
      ];

      commonPrint('croc send args: $args');

      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.connecting,
        codePhrase: code,
      );

      final process = await Process.start(_crocPath!, args);
      _process = process;

      await for (final line in process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        final progress = _parseOutput(line, transferId);
        if (progress != null) yield progress;
      }

      final exitCode = await process.exitCode;
      _process = null;

      if (exitCode == 0) {
        yield TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.completed,
        );
      } else {
        final stderr = await process.stderr
            .transform(utf8.decoder)
            .join();
        yield TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.failed,
          error: 'croc exited with code $exitCode: $stderr',
        );
      }
    } catch (e) {
      _process = null;
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.failed,
        error: e.toString(),
      );
    }
  }

  @override
  Stream<TransferProgress> receiveFiles(ReceiveOptions options) async* {
    if (_crocPath == null || !_isAvailable) {
      yield const TransferProgress(
        status: TransferProgressStatus.failed,
        error: 'croc binary not available. Run `flutter_croc_setup` to download.',
      );
      return;
    }

    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    yield TransferProgress(
      transferId: transferId,
      status: TransferProgressStatus.initializing,
    );

    try {
      final args = <String>[
        '--yes',
        if (options.overwrite) '--overwrite',
        if (options.onlyLocal) '--local',
        if (options.outputPath.isNotEmpty) '--out', options.outputPath,
        if (options.relayAddress != null && options.relayAddress!.isNotEmpty)
          '--relay', options.relayAddress!,
        if (options.relayPassword != null && options.relayPassword!.isNotEmpty)
          '--pass', options.relayPassword!,
        options.codePhrase,
      ];

      commonPrint('croc receive args: $args');

      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.connecting,
      );

      final process = await Process.start(_crocPath!, args);
      _process = process;

      await for (final line in process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        final progress = _parseOutput(line, transferId);
        if (progress != null) yield progress;
      }

      final exitCode = await process.exitCode;
      _process = null;

      if (exitCode == 0) {
        yield TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.completed,
        );
      } else {
        final stderr = await process.stderr
            .transform(utf8.decoder)
            .join();
        yield TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.failed,
          error: 'croc exited with code $exitCode: $stderr',
        );
      }
    } catch (e) {
      _process = null;
      yield TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.failed,
        error: e.toString(),
      );
    }
  }

  TransferProgress? _parseOutput(String line, String transferId) {
    if (line.contains('Code is:')) {
      final m = RegExp(r'Code is:\s*(\S+)').firstMatch(line);
      return TransferProgress(
        transferId: transferId,
        status: TransferProgressStatus.transferring,
        codePhrase: m?.group(1),
      );
    }
    if (RegExp(r'\d+%').hasMatch(line)) {
      final m = RegExp(r'(\d+)%').firstMatch(line);
      final pct = int.tryParse(m?.group(1) ?? '0') ?? 0;
      return TransferProgress(
        transferId: transferId,
        status: pct >= 100
            ? TransferProgressStatus.completed
            : TransferProgressStatus.transferring,
        transferredSize: pct,
        totalSize: 100,
      );
    }
    if (RegExp(r'\d+\.?\d*\s*[KM]B/s').hasMatch(line)) {
      final m = RegExp(r'(\d+\.?\d*)\s*([KM])B/s').firstMatch(line);
      if (m != null) {
        final speed = double.tryParse(m.group(1)!) ?? 0;
        final mult = m.group(2) == 'M' ? 1024 * 1024 : 1024;
        return TransferProgress(
          transferId: transferId,
          status: TransferProgressStatus.transferring,
          speed: speed * mult,
        );
      }
    }
    return null;
  }

  @override
  Future<bool> cancelTransfer(String transferId) async {
    if (_process != null) {
      _process!.kill();
      _process = null;
      return true;
    }
    return false;
  }

  @override
  Future<bool> shutdown() async {
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
    _isAvailable = false;
    return true;
  }
}
