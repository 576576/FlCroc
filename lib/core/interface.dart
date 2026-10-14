import 'dart:async';

import 'package:fl_croc/core/qr_matrix.dart';
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

  /// The web receive URL for [code] (`https://getcroc.com/?code=…`), or an empty
  /// string when this backend cannot supply one.
  ///
  /// This is the payload of the sender's QR code and the same URL `croc --qr`
  /// prints, so it comes from croc instead of being rebuilt here.
  String webReceiveUrl(String code);

  /// The QR module matrix for [text], or null when this backend cannot encode.
  ///
  /// Synchronous because the widget that draws it needs the matrix while it
  /// builds.
  QrMatrix? qrCodeMatrix(String text);
}
