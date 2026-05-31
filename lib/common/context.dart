import 'dart:io' show Platform;

import 'package:fl_croc/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  AppLocalizations get appLocalizations => AppLocalizations.of(this);

  /// Show a brief notification. Uses toast on Android/iOS, SnackBar elsewhere.
  void showSnackBar(String message) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(msg: message);
    } else {
      ScaffoldMessenger.of(this)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    }
  }
}
