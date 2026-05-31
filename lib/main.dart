import 'dart:async';
import 'dart:io';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_receiver/share_receiver.dart';
import 'package:window_manager/window_manager.dart';

import 'application.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Hide native title bar via window_manager (handles DWM frame & rounded corners properly).
    if (isWindows || isLinux) {
      await windowManager.ensureInitialized();
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setMinimumSize(const Size(400, 500));
    }

    await AppPrefs.init();
    final version = 1;
    final container = await globalState.init(version);

    // ── Share intent handling (Android / iOS "Open with") ──
    if (Platform.isAndroid || Platform.isIOS) {
      _initShareReceiver(container);
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Init Error: $e\n$s')),
        ),
      ),
    );
  }
}

void _initShareReceiver(ProviderContainer container) async {
  final receiver = ShareReceiver.instance;
  await receiver.initialize();

  // Cold start: app launched via share
  final initial = await receiver.getInitialSharing();
  if (initial != null && initial.filePaths.isNotEmpty) {
    _handleSharedFiles(container, initial.filePaths);
    await receiver.clear();
  }

  // Warm start: share while app is already running
  receiver.getMediaStream().listen((SharedData data) {
    if (data.filePaths.isNotEmpty) {
      _handleSharedFiles(container, data.filePaths);
      receiver.clear();
    }
  });
}

void _handleSharedFiles(ProviderContainer container, List<String> paths) {
  container.read(pendingSharedFilesProvider.notifier).state = paths;
  container.read(appStateProvider.notifier).updatePageLabel(PageLabel.send);
}
