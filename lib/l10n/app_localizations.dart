/// FlCroc internationalization (i18n).
///
/// Translations are stored in JSON bundles under `assets/bundles/`.
/// Script variants (e.g. `zh-Hant`) only need to override keys that differ
/// from the base language — missing keys fall back automatically.
library;

import 'dart:convert';

import 'package:fl_croc/common/print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('ja'),
    Locale('fr'),
  ];

  /// Look up a message by key. Falls back to the key itself.
  String _(String key) => _messages[key] ?? key;

  /// All registered translation keys (must match `assets/bundles/*.json`).
  /// Add new keys here AND in both JSON bundles.
  static const allKeys = <String>{
    // ── Common: App ──
    'appName',

    // ── Common: Navigation ──
    'dashboard', 'send', 'receive', 'history', 'settings',

    // ── Common: File / Text ──
    'file', 'text', 'selectFiles', 'selectTextFile', 'sentText',
    'noFiles', 'noReceivedFiles',

    // ── Common: Actions ──
    'cancel', 'confirm', 'clear', 'delete', 'copy',
    'paste', 'generate', 'edit', 'done', 'retry',
    'open', 'openFolder',

    // ── Common: Status ──
    'justNow', 'minAgo', 'hoursAgo', 'daysAgo', 'monthsAgo',
    'loading', 'connecting', 'pending', 'sending', 'transferring',
    'receiving', 'completed', 'failed', 'cancelled',
    'default', 'custom',

    // ── Common: Errors ──
    'noCrocBackend', 'sendFailed', 'receiveFailed',
    'errorRoomNotReady', 'errorRelayPassword', 'errorCouldNotConnect',
    'errorCodeIncorrect',

    // ── Common: Update ──
    'checkUpdate', 'alreadyLatest', 'newVersionAvailable',
    'latestVersion', 'currentVersion', 'update',
    'updateChannel', 'releaseChannel', 'nightlyChannel', 'autoCheckUpdate',

    // ── Dashboard ──
    'transferSpeed', 'transferStatsName', 'totalTransferred', 'quickTransfer',
    'quickSettings', 'quickSameCode',
    'quickSendCode', 'quickRecvCode', 'quickSRCode',
    'quickEnterCode', 'quickEmptyRecvCode',
    'quickEmptySendCode', 'recentTransfers',
    'transfersUnit', 'noTransfersYet',
    'noHistory', 'availableWidgets',

    // ── Send ──
    'codePhrase', 'enterCodePhrase', 'phraseHintCroc', 'phraseHintRandom',
    'textHint', 'textSizeLimit', 'unlimited',
    'autoGeneratePhrase', 'phraseMode',
    'phraseModeOn', 'autoCopyPhrase',
    'enterPhraseWarning', 'enterTextWarning',

    // ── Receive ──
    'startReceive', 'scanQRCode', 'generateQRCode', 'whiteBgQR', 'phraseEmpty',
    'selectQRImage', 'flashlight', 'flipCamera', 'noQRFound', 'scanMobileOnly',
    'cameraPermissionDenied', 'cameraUnsupported', 'cameraError',

    // ── Settings: Transfer Options ──
    'options', 'transferOptions', 'encryptionCurve', 'hashAlgorithm',
    'enableCompression', 'overwrite', 'zipFolder',

    // ── Settings: Relay ──
    'relayType', 'relaySettings', 'relayAddress', 'relayPassword',
    'defaultRelay', 'customRelay', 'noRelay', 'port', 'resetRelay',

    // ── Settings: Save Path ──
    'storageFolder', 'defaultSavePath', 'selectFolder', 'savePath',

    // ── Settings: Theme ──
    'theme', 'themeMode', 'light', 'dark', 'system',
    'language', 'autoLanguage', 'pureBlackMode', 'colorPalette',

    // ── Settings: Navigation ──
    'noTextMode', 'noTextModeDesc',
    'disableAnimations', 'disableAnimationsDesc',

    // ── Settings: Reset ──
    'reset', 'resetAllSettings', 'resetAllConfirm', 'settingsReset',

    // ── Send ──
    'dragHere', 'dropToAdd',

    // ── Settings: Debug ──
    'debug', 'debugLog', 'debugModeOn', 'debugModeOff',
    'debugTapEnable', 'debugTapDisable',
    'autoClearLog', 'autoClearLogDesc', 'noLogs',
    'exportLog', 'logExported',

    // ── Settings: About ──
    'about', 'application', 'appVersion', 'crocVersion',
    'unavailable', 'description',

    // ── Settings: Acknowledgments ──
    'acknowledgments', 'openSourceProjects',
    'flutterDesc', 'crocDesc', 'flClashDesc', 'crocAppDesc',
  };

  // ═══════════════════════════════════════════════════════════
  // Typed getters (one per key in allKeys)
  // ═══════════════════════════════════════════════════════════

  // ── Common: App ──
  String get appName => _('appName');

  // ── Common: Navigation ──
  String get dashboard => _('dashboard');
  String get send => _('send');
  String get receive => _('receive');
  String get history => _('history');
  String get settings => _('settings');

  // ── Common: File / Text ──
  String get file => _('file');
  String get text => _('text');
  String get selectFiles => _('selectFiles');
  String get selectTextFile => _('selectTextFile');
  String get sentText => _('sentText');
  String get noFiles => _('noFiles');
  String get noReceivedFiles => _('noReceivedFiles');

  // ── Common: Actions ──
  String get cancel => _('cancel');
  String get confirm => _('confirm');
  String get clear => _('clear');
  String get delete => _('delete');
  String get copy => _('copy');
  String get paste => _('paste');
  String get generate => _('generate');
  String get edit => _('edit');
  String get done => _('done');
  String get retry => _('retry');
  String get open => _('open');
  String get openFolder => _('openFolder');

  // ── Common: Status ──
  String get justNow => _('justNow');
  String get minAgo => _('minAgo');
  String get hoursAgo => _('hoursAgo');
  String get daysAgo => _('daysAgo');
  String get monthsAgo => _('monthsAgo');
  String get loading => _('loading');
  String get connecting => _('connecting');
  String get pending => _('pending');
  String get sending => _('sending');
  String get transferring => _('transferring');
  String get receiving => _('receiving');
  String get completed => _('completed');
  String get failed => _('failed');
  String get cancelled => _('cancelled');
  String get codeCopied => _('codeCopied');
  String get codePasted => _('codePasted');
  String get copied => _('copied');
  String get pasted => _('pasted');
  String get cleared => _('cleared');
  String get historyCleared => _('historyCleared');
  String get defaultLabel => _('default');
  String get custom => _('custom');

  // ── Common: Errors ──
  String get noCrocBackend => _('noCrocBackend');
  String get sendFailed => _('sendFailed');
  String get receiveFailed => _('receiveFailed');
  String get errorRoomNotReady => _('errorRoomNotReady');
  String get errorRelayPassword => _('errorRelayPassword');
  String get errorCouldNotConnect => _('errorCouldNotConnect');

  /// 将 croc 原始错误信息映射为本地化文案。
  /// Debug 模式下直接返回原始错误信息。
  String localizeCrocError(String error, {bool isSend = false}) {
    if (LogBuffer.debugMode) return error;
    final lower = error.toLowerCase();
    if (lower.contains('room (secure channel) not ready')) return errorRoomNotReady;
    if (lower.contains('bad password')) return errorRelayPassword;
    if (lower.contains('i/o timeout')) return errorCouldNotConnect;
    return isSend ? sendFailed : receiveFailed;
  }

  // ── Common: Update ──
  String get checkUpdate => _('checkUpdate');
  String get alreadyLatest => _('alreadyLatest');
  String get newVersionAvailable => _('newVersionAvailable');
  String get latestVersion => _('latestVersion');
  String get currentVersion => _('currentVersion');
  String get update => _('update');
  String get updateChannel => _('updateChannel');
  String get releaseChannel => _('releaseChannel');
  String get nightlyChannel => _('nightlyChannel');
  String get autoCheckUpdate => _('autoCheckUpdate');

  // ── Dashboard ──
  String get transferSpeed => _('transferSpeed');
  String get transferStatsName => _('transferStatsName');
  String get totalTransferred => _('totalTransferred');
  String get quickTransfer => _('quickTransfer');
  String get quickSettings => _('quickSettings');
  String get quickSameCode => _('quickSameCode');
  String get quickSendCode => _('quickSendCode');
  String get quickRecvCode => _('quickRecvCode');
  String get quickSRCode => _('quickSRCode');
  String get quickEnterCode => _('quickEnterCode');
  String get quickEmptyRecvCode => _('quickEmptyRecvCode');
  String get quickEmptySendCode => _('quickEmptySendCode');
  String get recentTransfers => _('recentTransfers');
  String get transfersUnit => _('transfersUnit');
  String get noTransfersYet => _('noTransfersYet');
  String get noHistory => _('noHistory');
  String get availableWidgets => _('availableWidgets');

  // ── Send ──
  String get codePhrase => _('codePhrase');
  String get enterCodePhrase => _('enterCodePhrase');
  String get phraseHintCroc => _('phraseHintCroc');
  String get phraseHintRandom => _('phraseHintRandom');
  String get textHint => _('textHint');
  String get textSizeLimit => _('textSizeLimit');
  String get unlimited => _('unlimited');
  String get autoGeneratePhrase => _('autoGeneratePhrase');
  String get phraseMode => _('phraseMode');
  String get phraseModeOn => _('phraseModeOn');
  String get autoCopyPhrase => _('autoCopyPhrase');
  String get enterPhraseWarning => _('enterPhraseWarning');
  String get enterTextWarning => _('enterTextWarning');

  // ── Receive ──
  String get startReceive => _('startReceive');
  String get scanQRCode => _('scanQRCode');
  String get generateQRCode => _('generateQRCode');
  String get whiteBgQR => _('whiteBgQR');
  String get phraseEmpty => _('phraseEmpty');
  String get selectQRImage => _('selectQRImage');
  String get flashlight => _('flashlight');
  String get flipCamera => _('flipCamera');
  String get noQRFound => _('noQRFound');
  String get scanMobileOnly => _('scanMobileOnly');
  String get cameraPermissionDenied => _('cameraPermissionDenied');
  String get cameraUnsupported => _('cameraUnsupported');
  String get cameraError => _('cameraError');

  // ── Settings: Transfer Options ──
  String get options => _('options');
  String get transferOptions => _('transferOptions');
  String get encryptionCurve => _('encryptionCurve');
  String get hashAlgorithm => _('hashAlgorithm');
  String get enableCompression => _('enableCompression');
  String get overwrite => _('overwrite');
  String get zipFolder => _('zipFolder');

  // ── Settings: Relay ──
  String get relayType => _('relayType');
  String get relaySettings => _('relaySettings');
  String get relayAddress => _('relayAddress');
  String get relayPassword => _('relayPassword');
  String get defaultRelay => _('defaultRelay');
  String get customRelay => _('customRelay');
  String get noRelay => _('noRelay');
  String get port => _('port');
  String get resetRelay => _('resetRelay');

  // ── Settings: Save Path ──
  String get storageFolder => _('storageFolder');
  String get defaultSavePath => _('defaultSavePath');
  String get selectFolder => _('selectFolder');
  String get savePath => _('savePath');

  // ── Settings: Theme ──
  String get theme => _('theme');
  String get themeMode => _('themeMode');
  String get light => _('light');
  String get dark => _('dark');
  String get system => _('system');
  String get language => _('language');
  String get autoLanguage => _('autoLanguage');
  String get pureBlackMode => _('pureBlackMode');
  String get colorPalette => _('colorPalette');

  // ── Settings: Navigation ──
  String get noTextMode => _('noTextMode');
  String get noTextModeDesc => _('noTextModeDesc');
  String get disableAnimations => _('disableAnimations');
  String get disableAnimationsDesc => _('disableAnimationsDesc');

  // ── Settings: Reset ──
  String get reset => _('reset');
  String get resetAllSettings => _('resetAllSettings');
  String get resetAllConfirm => _('resetAllConfirm');
  String get settingsReset => _('settingsReset');

  // ── Send ──
  String get dropToAdd => _('dropToAdd');

  // ── Settings: Debug ──
  String get debug => _('debug');
  String get debugLog => _('debugLog');
  String get debugModeOn => _('debugModeOn');
  String get debugModeOff => _('debugModeOff');

  /// Show countdown hint: "Press N more times to enable/disable debug mode".
  String debugTapHint(int remaining, {required bool enable}) {
    final key = enable ? 'debugTapEnable' : 'debugTapDisable';
    return _(key).replaceAll('{count}', '$remaining');
  }
  String get autoClearLog => _('autoClearLog');
  String get autoClearLogDesc => _('autoClearLogDesc');
  String get noLogs => _('noLogs');
  String get exportLog => _('exportLog');
  String logExported(String path) => _('logExported').replaceAll('{0}', path);

  // ── Settings: About ──
  String get about => _('about');
  String get application => _('application');
  String get appVersion => _('appVersion');
  String get crocVersion => _('crocVersion');
  String get unavailable => _('unavailable');
  String get description => _('description');

  // ── Settings: Acknowledgments ──
  String get acknowledgments => _('acknowledgments');
  String get openSourceProjects => _('openSourceProjects');
  String get flutterDesc => _('flutterDesc');
  String get crocDesc => _('crocDesc');
  String get flClashDesc => _('flClashDesc');
  String get crocAppDesc => _('crocAppDesc');

  /// Map [PageLabel] to its localized display name.
  String pageLabel(Enum label) {
    switch (label.name) {
      case 'dashboard':
        return dashboard;
      case 'send':
        return send;
      case 'receive':
        return receive;
      case 'history':
        return history;
      case 'settings':
        return settings;
      default:
        return label.name;
    }
  }

  /// Map [DashboardWidget] to its localized display name.
  String dashboardWidgetName(Enum widget) {
    switch (widget.name) {
      case 'transferStats':
        return transferStatsName;
      case 'transferSpeed':
        return transferSpeed;
      case 'totalTransferred':
        return totalTransferred;
      case 'quickTransfer':
        return quickTransfer;
      case 'recentTransfers':
        return recentTransfers;
      default:
        return widget.name;
    }
  }
}

// ────────────────────────────────────────────────────────────
// Delegate
// ────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _cache = {};

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) =>
        l.languageCode == locale.languageCode &&
        (l.scriptCode == null || l.scriptCode == locale.scriptCode));

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final code = locale.scriptCode != null
        ? '${locale.languageCode}-${locale.scriptCode}'
        : locale.languageCode;

    // Load exact match + base language, merge (variant overrides base).
    // E.g. zh-Hant → zh-Hant.json overlaid on zh.json.
    Map<String, String> messages = await _loadBundle(code);
    if (code != locale.languageCode) {
      final base = await _loadBundle(locale.languageCode);
      messages = {...base, ...messages};
    }

    if (messages.isEmpty) messages = await _loadBundle('en');
    return AppLocalizations._(locale, messages);
  }

  Future<Map<String, String>> _loadBundle(String code) async {
    if (_cache.containsKey(code)) return _cache[code]!;
    try {
      final json = await rootBundle.loadString('assets/bundles/$code.json');
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final map = <String, String>{};
      for (final entry in decoded.entries) {
        if (entry.value is String) map[entry.key] = entry.value as String;
      }
      return _cache[code] = map;
    } catch (_) {
      return _cache[code] = {};
    }
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
