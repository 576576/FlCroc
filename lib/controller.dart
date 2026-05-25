import 'dart:async';

import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppController {
  late final WidgetRef _ref;
  bool isAttach = false;

  static AppController? _instance;

  AppController._internal();

  factory AppController() {
    _instance ??= AppController._internal();
    return _instance!;
  }

  Future<void> attach(BuildContext context, WidgetRef ref) async {
    _ref = ref;
    isAttach = true;

    // Initialize croc backend (FFI or process-based)
    final ok = await coreController.init();
    if (ok) {
      await updateCoreStatus(CoreStatus.connected);
    } else {
      await updateCoreStatus(CoreStatus.disconnected);
    }
  }

  void detach() {
    isAttach = false;
  }

  void toPage(PageLabel label) {
    _ref.read(appStateProvider.notifier).updatePageLabel(label);
  }

  Future<void> updateCoreStatus(CoreStatus status) {
    _ref.read(appStateProvider.notifier).updateCoreStatus(status);
    return Future.value();
  }

  void addTransferRecord(TransferRecord record) {
    _ref.read(appStateProvider.notifier).addTransfer(record);
  }

  void updateTransferRecord(TransferRecord record) {
    _ref.read(appStateProvider.notifier).updateTransfer(record);
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<bool> showDisclaimer() async {
    final result = await globalState.showMessage(
      text: const TextSpan(text: 'This software is for non-commercial use only.'),
    );
    return result ?? false;
  }

  void clearHistory() {
    _ref.read(appStateProvider.notifier).clearTransfers();
  }

  void navigateTo(PageLabel label) {
    _ref.read(appStateProvider.notifier).updatePageLabel(label);
  }
}

final appController = AppController();
