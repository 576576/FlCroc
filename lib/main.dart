import 'dart:async';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
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
