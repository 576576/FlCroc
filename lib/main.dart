import 'dart:async';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'application.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Hide native title bar via window_manager (handles DWM frame & rounded corners properly).
    if (isWindows || isLinux) {
      await windowManager.ensureInitialized();
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }

    await AppPrefs.init();
    final version = 1;
    final container = await globalState.init(version);
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
