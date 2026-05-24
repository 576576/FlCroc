import 'dart:async';

import 'package:fl_croc/models/models.dart';

abstract class CoreInterface {
  Future<bool> init();

  Future<String> getVersion();

  Future<String> generateCodePhrase();

  Stream<TransferProgress> sendFiles(SendOptions options);

  Stream<TransferProgress> receiveFiles(ReceiveOptions options);

  Future<bool> cancelTransfer(String transferId);

  Future<bool> shutdown();

  bool get isAvailable;
}
