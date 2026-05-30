import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart' hide ResultType;
import 'package:url_launcher/url_launcher.dart';

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  factory GlobalState() => _instance;
  GlobalState._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late PackageInfo packageInfo;
  late CommonTheme theme;
  bool isInit = false;

  Future<ProviderContainer> init(int version) async {
    packageInfo = await PackageInfo.fromPlatform();

    // 初始化跨平台下载路径缓存
    await AppPaths.init();

    final container = ProviderContainer();

    // SharedPreferences may be corrupted from IDE crash — delete bad file & retry.
    // (Desktop only: on Android/iOS SharedPreferences uses platform-native storage.)
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      if (isDesktop) {
        try {
          final supportDir = await getApplicationSupportDirectory();
          final prefsFile = File('${supportDir.path}${Platform.pathSeparator}shared_preferences.json');
          if (await prefsFile.exists()) {
            await prefsFile.delete();
          }
          prefs = await SharedPreferences.getInstance();
        } catch (_) {
          prefs = null;
        }
      }
    }

    AppSettingProps config;
    if (prefs != null) {
      final configJson = prefs.getString('app_settings');
      try {
        if (configJson != null && configJson.isNotEmpty) {
          config = AppSettingProps.fromJson(
            Map<String, Object?>.from(
              const JsonDecoder().convert(configJson) as Map,
            ),
          );
        } else {
          config = const AppSettingProps();
        }
      } catch (_) {
        config = const AppSettingProps();
      }
    } else {
      config = const AppSettingProps();
    }

    container.read(appSettingProvider.notifier).update((_) => config);

    try {
      await container.read(themeSettingProvider.notifier).load();
    } catch (_) {
      // Theme settings corrupted — use defaults.
    }

    container.read(appStateProvider.notifier).setInit(true);

    isInit = true;
    return container;
  }

  Future<bool?> showMessage({
    required TextSpan text,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text.rich(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<T?> showCommonDialog<T>({
    required Widget child,
    BuildContext? context,
    bool dismissible = true,
  }) async {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return null;
    return await showDialog<T>(
      context: ctx,
      barrierDismissible: dismissible,
      builder: (_) => child,
    );
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      commonPrint('Failed to open URL: $e');
    }
  }

  Future<void> openFile(String path) async {
    if (path.isEmpty) return;
    try {
      final result = await OpenFilex.open(path);
      if (result.message.isNotEmpty) {
        commonPrint('Open file result: ${result.message}');
      }
    } catch (e) {
      commonPrint('Failed to open file: $e');
    }
  }

  Future<void> openFolder(String filePath) async {
    if (filePath.isEmpty) return;
    try {
      if (Platform.isWindows) {
        final isDir = Directory(filePath).existsSync();
        if (isDir) {
          await Process.run('explorer', [filePath]);
        } else {
          await Process.run('explorer', ['/select,', filePath]);
        }
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
      } else {
        // Android / iOS: open parent folder via downloadsfolder
        final dir = Directory(filePath).existsSync()
            ? filePath
            : File(filePath).parent.path;
        await OpenFilex.open(dir);
      }
    } catch (e) {
      commonPrint('Failed to open folder: $e');
    }
  }
}

final globalState = GlobalState();
