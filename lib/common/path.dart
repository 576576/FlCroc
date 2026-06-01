import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:fl_croc/common/print.dart';
import 'package:path_provider/path_provider.dart';

/// 跨平台存储路径工具，基于 [downloadsfolder] 插件。
///
/// - **默认保存路径**：桌面端使用系统 Downloads；Android/iOS 使用应用专属存储
///   （Go 桥接需要真实文件系统路径）。
/// - **导出到公共 Downloads**：通过 [copyFileIntoDownloadFolder] 实现，
///   Android 10+ 自动走 MediaStore 兼容分区存储。
class AppPaths {
  static String? _cachedPath;

  // ── 默认保存路径（Go 桥接可直接写入） ──

  static Future<String> getDefaultSavePath() async {
    if (_cachedPath != null) return _cachedPath!;

    if (Platform.isAndroid) {
      try {
        final dir = await getExternalStorageDirectory();
        if (dir != null) {
          _cachedPath = '${dir.path}${Platform.pathSeparator}FlCroc';
          await Directory(_cachedPath!).create(recursive: true);
          return _cachedPath!;
        }
      } catch (_) {}
    }

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final sub = Platform.isAndroid ? 'FlCroc' : '';
        _cachedPath = sub.isEmpty ? dir.path : '${dir.path}${Platform.pathSeparator}$sub';
        if (sub.isNotEmpty) await Directory(_cachedPath!).create(recursive: true);
        return _cachedPath!;
      } catch (_) {}
    }

    // 桌面端：系统 Downloads 目录
    try {
      final dir = await getDownloadDirectory();
      _cachedPath = dir.path;
      return _cachedPath!;
    } catch (_) {}

    _cachedPath = _fallbackPath();
    return _cachedPath!;
  }

  static String get savePathSync {
    if (_cachedPath != null) return _cachedPath!;
    return _fallbackPath();
  }

  // ── 导出到公共 Downloads（Android 10+ 走 MediaStore） ──

  /// 将文件导出到系统 Downloads 目录。
  /// Android 10+ 自动使用 MediaStore；桌面端直接复制。
  static Future<String?> exportToDownloads(String sourcePath) async {
    final fileName = sourcePath.split(Platform.pathSeparator).last;
    try {
      final ok = await copyFileIntoDownloadFolder(sourcePath, fileName);
      if (ok == true) {
        final dir = await getDownloadDirectory();
        return '${dir.path}${Platform.pathSeparator}$fileName';
      }
    } catch (e) {
      commonPrint('exportToDownloads failed: $e');
    }
    return sourcePath; // 保持原位
  }

  /// 在系统文件管理器中打开 Downloads 目录。
  static Future<bool> openDownloadsFolder() => openDownloadFolder();

  /// 检查路径是否为可写的真实文件系统路径（非 content URI）。
  static bool isWritablePath(String path) {
    if (path.isEmpty) return false;
    if (path.startsWith('content://')) return false;
    try {
      final dir = Directory(path);
      if (!dir.existsSync()) return true; // 可创建
      // 尝试创建临时文件验证可写
      final testFile = File('$path${Platform.pathSeparator}.flcroc_write_test');
      testFile.writeAsStringSync('test');
      testFile.deleteSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── 初始化 ──

  static Future<void> init() async {
    await getDefaultSavePath();
  }

  // ── 内部 ──

  static String _fallbackPath() {
    try {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final dir = Directory('$exeDir${Platform.pathSeparator}out');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      return dir.path;
    } catch (_) {
      if (Platform.isWindows) return 'C:\\';
      if (Platform.isAndroid) return '/storage/emulated/0/Android/data/cn.sumitm.flcroc/files/FlCroc';
      return '/';
    }
  }
}

/// 保存路径的 UI 显示标签（接受本地化对象）。
String formatPathForDisplay(String path, {String? downloadsLabel}) {
  if (path.isEmpty) return downloadsLabel ?? 'Downloads';
  // Android app-specific or iOS sandbox path → show friendly label
  if (Platform.isAndroid && path.contains('/Android/data/')) {
    return downloadsLabel ?? 'Downloads';
  }
  if (Platform.isIOS && path.contains('/Documents')) {
    return downloadsLabel ?? 'Downloads';
  }
  return path;
}

