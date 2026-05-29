import 'dart:async';

import 'package:fl_croc/core/interface.dart';
import 'package:fl_croc/models/models.dart';

/// Web stub for CoreLib — FFI not available on web.
class CoreLib extends CoreInterface {
  static CoreLib? _instance;

  CoreLib._internal();

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  static const builtinCrocVersion = '10.4.4';

  @override
  bool get isAvailable => false;

  @override
  Future<bool> init() async => false;

  @override
  Future<String> getVersion() async => builtinCrocVersion;

  @override
  Future<String> generateCodePhrase() async {
    final rng = DateTime.now().microsecondsSinceEpoch;
    const adjectives = ['swift', 'bold', 'calm', 'keen', 'warm', 'cool'];
    const nouns = ['falcon', 'jaguar', 'python', 'raven', 'otter'];
    const verbs = ['dash', 'zoom', 'glide', 'soar', 'rush'];
    return '${adjectives[rng % adjectives.length]}-'
        '${nouns[(rng ~/ 2) % nouns.length]}-'
        '${verbs[(rng ~/ 3) % verbs.length]}';
  }

  @override
  Stream<TransferProgress> sendFiles(SendOptions options) async* {
    yield const TransferProgress(
      status: TransferProgressStatus.failed,
      error: 'croc backend not supported on web',
    );
  }

  @override
  Stream<TransferProgress> receiveFiles(ReceiveOptions options) async* {
    yield const TransferProgress(
      status: TransferProgressStatus.failed,
      error: 'croc backend not supported on web',
    );
  }

  @override
  Future<bool> cancelTransfer(String transferId) async => false;

  @override
  Future<bool> shutdown() async => true;
}
