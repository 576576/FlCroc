import 'dart:developer' as dev;

void commonPrint(String message) {
  dev.log(message, name: 'FlCroc');
}

extension PrintExt on String {
  void get log => commonPrint(this);
}
