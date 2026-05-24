/// FlCroc internationalization (i18n).
///
/// **Architecture** — code and translations are fully decoupled:
///   - This file: `AppLocalizations` class with typed getters
///   - `intl/messages_en.dart` — English `Map<String, String>`
///   - `intl/messages_zh.dart` — Chinese `Map<String, String>`
///
/// **Adding a new language:**
///   1. Create `intl/messages_xx.dart` exporting a `const Map<String, String>`
///   2. Import and add to `_lookupMap` in the delegate below
///   3. Add the locale to `supportedLocales`
library;

import 'package:flutter/material.dart';

import 'intl/messages_en.dart';
import 'intl/messages_zh.dart';

// ────────────────────────────────────────────────────────────
// AppLocalizations
// ────────────────────────────────────────────────────────────

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _messages;

  AppLocalizations._(this.locale, this._messages);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh', 'CN'),
  ];

  /// Look up a message by key. Falls back to the key itself.
  String _(String key) => _messages[key] ?? key;

  // ── Typed getters ──

  String get appName => _('appName');

  String get dashboard => _('dashboard');
  String get send => _('send');
  String get receive => _('receive');
  String get history => _('history');
  String get settings => _('settings');

  String get transferSpeed => _('transferSpeed');
  String get totalTransferred => _('totalTransferred');
  String get quickSend => _('quickSend');
  String get recentTransfers => _('recentTransfers');
  String get crocStatus => _('crocStatus');

  String get selectFiles => _('selectFiles');
  String get startSend => _('startSend');
  String get codePhrase => _('codePhrase');
  String get enterCodePhrase => _('enterCodePhrase');
  String get startReceive => _('startReceive');
  String get scanQRCode => _('scanQRCode');

  String get relaySettings => _('relaySettings');
  String get relayAddress => _('relayAddress');
  String get relayPassword => _('relayPassword');
  String get defaultRelay => _('defaultRelay');
  String get customRelay => _('customRelay');

  String get theme => _('theme');
  String get themeMode => _('themeMode');
  String get light => _('light');
  String get dark => _('dark');
  String get system => _('system');
  String get language => _('language');
  String get pureBlackMode => _('pureBlackMode');

  String get about => _('about');
  String get application => _('application');
  String get appVersion => _('appVersion');
  String get desc => _('desc');

  String get transferOptions => _('transferOptions');
  String get encryptionCurve => _('encryptionCurve');
  String get hashAlgorithm => _('hashAlgorithm');
  String get compression => _('compression');
  String get overwrite => _('overwrite');
  String get zipFolder => _('zipFolder');
  String get localOnly => _('localOnly');
  String get excludePatterns => _('excludePatterns');

  String get cancel => _('cancel');
  String get confirm => _('confirm');
  String get delete => _('delete');
  String get clear => _('clear');
  String get exportData => _('exportData');
  String get copyCode => _('copyCode');
  String get codeCopied => _('codeCopied');
  String get confirmDelete => _('confirmDelete');
  String get checkUpdate => _('checkUpdate');

  String get noFiles => _('noFiles');
  String get noTransfers => _('noTransfers');
  String get noHistory => _('noHistory');
  String get connecting => _('connecting');
  String get transferring => _('transferring');
  String get completed => _('completed');
  String get failed => _('failed');
  String get cancelled => _('cancelled');

  String get loading => _('loading');
  String get retry => _('retry');
  String get edit => _('edit');
  String get done => _('done');
}

// ────────────────────────────────────────────────────────────
// Delegate
// ────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Language lookup registry.
  /// Add new languages by importing their message map and adding an entry here.
  static final Map<String, Map<String, String>> _lookupMap = {
    'en': enMessages,
    'zh': zhMessages,
  };

  @override
  bool isSupported(Locale locale) =>
      _lookupMap.containsKey(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final messages = _lookupMap[locale.languageCode] ??
        _lookupMap['en']!;
    return AppLocalizations._(locale, messages);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
