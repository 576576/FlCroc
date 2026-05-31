import 'dart:async';
import 'dart:io';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
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
      _initShareIntent(container);
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

void _initShareIntent(ProviderContainer container) {
  // Cold start: app launched via share
  ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      _handleSharedFiles(container, files);
    }
  });

  // Warm start: share while app is already running
  ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      _handleSharedFiles(container, files);
    }
  });
}

void _handleSharedFiles(ProviderContainer container, List<SharedMediaFile> files) {
  final paths = files.map((f) => f.path).where((p) => p.isNotEmpty).toList();
  if (paths.isEmpty) return;
  container.read(pendingSharedFilesProvider.notifier).state = paths;
  // Navigate to send page (post-frame so UI is ready)
  container.read(appStateProvider.notifier).updatePageLabel(PageLabel.send);
}
