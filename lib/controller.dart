import 'dart:async';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppController {
  late final BuildContext _context;
  late final WidgetRef _ref;
  bool isAttach = false;

  static AppController? _instance;

  AppController._internal();

  factory AppController() {
    _instance ??= AppController._internal();
    return _instance!;
  }

  Future<void> attach(BuildContext context, WidgetRef ref) async {
    _context = context;
    _ref = ref;
    isAttach = true;
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
}

final appController = AppController();
