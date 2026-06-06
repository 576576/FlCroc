import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'acknowledgments.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  String _crocVersion = '...';
  bool _debugMode = false;
  int _versionTaps = 0;
  DateTime? _lastVersionTap;
  bool _autoClearLog = true;

  // ── Reset long-press (2s UI change, 3s trigger) ──
  Timer? _resetTimer;
  double _resetProgress = 0;
  bool _resetPressing = false;
  bool _showResetUI = false;

  late final _relayAddrCtrl = TextEditingController();
  late final _relayPortCtrl = TextEditingController();
  late final _relayPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _debugMode = LogBuffer.debugMode;
    // Delay version check until after core controller initializes (post first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCrocVersion());
    final relay = ref.read(appSettingProvider).relayConfig;
    _relayAddrCtrl.text = relay.address;
    _relayPortCtrl.text = relay.port;
    _relayPassCtrl.text = relay.password;
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _relayAddrCtrl.dispose();
    _relayPortCtrl.dispose();
    _relayPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCrocVersion() async {
    try {
      final v = await coreController.getVersion();
      if (mounted) setState(() => _crocVersion = v);
    } catch (_) {
      if (mounted) setState(() => _crocVersion = 'unavailable');
    }
  }

  Future<void> _checkForUpdate(BuildContext context) async {
    final l10n = context.appLocalizations;
    final currentVer = globalState.packageInfo.version;
    final currentBuild = globalState.packageInfo.buildNumber;
    final channel = ref.read(appSettingProvider).updateChannel;

    try {
      final client = HttpClient();
      try {
        final tag = channel == UpdateChannel.nightly ? 'tags/nightly' : 'releases/latest';
        final uri = Uri.https('api.github.com', '/repos/$repository/$tag');
        final request = await client.getUrl(uri);
        request.headers.set('User-Agent', 'FlCroc');
        request.headers.set('Accept', 'application/vnd.github+json');
        final response = await request.close();
        if (response.statusCode != 200) {
          if (mounted) context.showSnackBar(l10n.alreadyLatest);
          return;
        }
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final latestTag = (data['tag_name'] as String?)?.replaceFirst(RegExp(r'^v'), '') ?? '';

        // Nightly channel: compare build number from release title
        if (channel == UpdateChannel.nightly) {
          final title = (data['name'] as String?) ?? '';
          final nightlyBuild = _parseBuildFromTitle(title);
          final curBuild = int.tryParse(currentBuild) ?? 0;
          if (nightlyBuild <= curBuild) {
            if (mounted) context.showSnackBar(l10n.alreadyLatest);
            return;
          }
          final displayVer = _parseVersionFromTitle(title) ?? latestTag;
          if (mounted) _showUpdateDialog(context, l10n, displayVer, currentVer, nightlyBuild, curBuild);
          return;
        }

        // Release channel: compare base version
        if (latestTag.isEmpty || _isSameOrOlder(latestTag, currentVer)) {
          if (mounted) context.showSnackBar(l10n.alreadyLatest);
          return;
        }
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.newVersionAvailable),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.latestVersion}: $latestTag'),
                  const SizedBox(height: 4),
                  Text('${l10n.currentVersion}: $currentVer'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    globalState.openUrl('https://github.com/$repository/releases');
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.update),
                ),
              ],
            ),
          );
        }
      } finally {
        client.close();
      }
    } catch (_) {
      if (mounted) context.showSnackBar(l10n.alreadyLatest);
    }
  }

  /// Returns true if [latest] is the same base version as [current] or older.
  /// Strips pre-release suffixes (e.g. -beta, -alpha) before comparing.
  bool _isSameOrOlder(String latest, String current) {
    final latestBase = latest.split(RegExp(r'[-+]')).first;
    final currentBase = current.split(RegExp(r'[-+]')).first;
    // Parse as integer parts for proper numeric comparison
    final latestParts = latestBase.split('.').map(int.tryParse).toList();
    final currentParts = currentBase.split('.').map(int.tryParse).toList();
    final length = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;
    for (int i = 0; i < length; i++) {
      final l = i < latestParts.length ? (latestParts[i] ?? 0) : 0;
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      if (l > c) return false; // latest is newer
      if (l < c) return true;  // latest is older
    }
    return true; // same base version — consider already latest
  }

  /// Extract build number from nightly title like "Nightly 1.2.2+63 2026-06-01".
  int _parseBuildFromTitle(String title) {
    final match = RegExp(r'\+(\d+)').firstMatch(title);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  /// Extract version from nightly title like "Nightly 1.2.2+63 2026-06-01".
  String? _parseVersionFromTitle(String title) {
    final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(title);
    return match?.group(1);
  }

  void _showUpdateDialog(BuildContext context, AppLocalizations l10n,
      String latestVer, String currentVer, int latestBuild, int currentBuild) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newVersionAvailable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.latestVersion}: $latestVer+$latestBuild'),
            const SizedBox(height: 4),
            Text('${l10n.currentVersion}: $currentVer+$currentBuild'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              globalState.openUrl('https://github.com/$repository/releases');
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  String _defaultDownloadPath() => AppPaths.savePathSync;

  Future<void> _pickSavePath(WidgetRef ref) async {
    final l10n = context.appLocalizations;
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    if (!AppPaths.isWritablePath(result)) {
      if (mounted) {
        context.showSnackBar(
          Platform.isAndroid
              ? '所选目录无法直接写入（Android 分区存储限制），已回退到默认保存路径'
              : 'Selected directory is not writable, using default path',
        );
      }
      return;
    }

    ref.read(appSettingProvider.notifier).update(
          (s) => s.copyWith(defaultSavePath: result),
        );
  }

  void _updateRelayControllers(String address, String port, String password) {
    _relayAddrCtrl.text = address;
    _relayPortCtrl.text = port;
    _relayPassCtrl.text = password;
  }

  Future<void> _resetAllSettings(BuildContext context) async {
    final l10n = context.appLocalizations;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetAllSettings),
        content: Text(l10n.resetAllConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.reset)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(appSettingProvider.notifier).resetAll();
    ref.read(themeSettingProvider.notifier).resetToDefault();
    if (mounted) context.showSnackBar(l10n.settingsReset);
  }

  void _startResetLongPress() {
    _resetTimer?.cancel();
    _resetPressing = true;
    _resetProgress = 0;
    _showResetUI = false;
    const tickMs = 50;
    _resetTimer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      if (!_resetPressing) {
        t.cancel();
        _resetProgress = 0;
        if (_showResetUI) setState(() => _showResetUI = false);
        return;
      }
      _resetProgress += tickMs / 3000.0;
      if (_resetProgress >= 2.0 / 3.0 && !_showResetUI) {
        _showResetUI = true;
      }
      if (_resetProgress >= 1.0) {
        t.cancel();
        _resetPressing = false;
        _resetProgress = 0;
        _showResetUI = false;
        setState(() {});
        _resetAllSettings(context);
        return;
      }
      setState(() {});
    });
    setState(() {});
  }

  void _cancelResetLongPress() {
    _resetPressing = false;
    _resetTimer?.cancel();
    _resetProgress = 0;
    if (_showResetUI) setState(() => _showResetUI = false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingProvider);

    final l10n = context.appLocalizations;
    return BaseScaffold(
      title: l10n.settings,
      body: ListView(
        children: [
          // Relay Settings
          ...generateSection(
            title: l10n.relaySettings,
            separated: false,
            items: [
              ListItem(
                leading: const Icon(Icons.dns),
                title: Text(l10n.relayType),
                subtitle: _buildRelayChips(appSettings.relayConfig.type, ref),
              ),
              if (appSettings.relayConfig.type == RelayType.customRelay) ...[
                _buildRelayField(
                  icon: Icons.link,
                  hint: l10n.relayAddress,
                  controller: _relayAddrCtrl,
                  suffix: IconButton(
                    icon: const Icon(Icons.restart_alt, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: l10n.resetRelay,
                    onPressed: () {
                      ref.read(appSettingProvider.notifier).update(
                            (s) => s.copyWith(
                              relayConfig: s.relayConfig.copyWith(
                                address: defaultRelay,
                                port: defaultPort,
                                password: defaultPassphrase,
                              ),
                            ),
                          );
                      _updateRelayControllers(defaultRelay, defaultPort, defaultPassphrase);
                    },
                  ),
                  onChanged: (v) {
                    ref.read(appSettingProvider.notifier).update(
                          (s) => s.copyWith(
                            relayConfig: s.relayConfig.copyWith(address: v),
                          ),
                        );
                  },
                ),
                _buildRelayField(
                  icon: Icons.numbers,
                  hint: l10n.port,
                  controller: _relayPortCtrl,
                  onChanged: (v) {
                    ref.read(appSettingProvider.notifier).update(
                          (s) => s.copyWith(
                            relayConfig: s.relayConfig.copyWith(port: v),
                          ),
                        );
                  },
                ),
                _buildPasswordField(
                  hint: l10n.relayPassword,
                  controller: _relayPassCtrl,
                  onChanged: (v) {
                    ref.read(appSettingProvider.notifier).update(
                          (s) => s.copyWith(
                            relayConfig: s.relayConfig.copyWith(password: v),
                          ),
                        );
                  },
                ),
              ],
            ],
          ),

          // Theme Settings
          ...generateSection(
            title: l10n.theme,
            separated: false,
            items: [
              ListItem(
                leading: const Icon(Icons.brightness_6),
                title: Text(l10n.themeMode),
                subtitle: _buildThemeModeChips(appSettings.themeMode, ref),
              ),
              // Pure black — only relevant when dark
              if (appSettings.themeMode == ThemeModeOption.dark ||
                  (appSettings.themeMode == ThemeModeOption.system &&
                      MediaQuery.of(context).platformBrightness == Brightness.dark)) ...[
                ListItem.switchItem(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(l10n.pureBlackMode),
                  delegate: SwitchDelegate(
                    value: appSettings.pureBlackMode,
                    onChanged: (v) {
                      ref.read(appSettingProvider.notifier).update(
                            (s) => s.copyWith(pureBlackMode: v),
                          );
                    },
                  ),
                ),
              ],
              ListItem(
                leading: Consumer(
                  builder: (_, ref, c) {
                    final primary = ref.watch(themeSettingProvider.select((s) => s.primaryColor));
                    return Icon(Icons.palette, color: cachedColorScheme(primary, Theme.of(context).brightness).primary);
                  },
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(l10n.colorPalette)),
                    Consumer(
                      builder: (_, ref, c) {
                        final current = ref.watch(themeSettingProvider.select((s) => s.primaryColor));
                        final isDefault = current == defaultPrimaryColor;
                        return TextButton.icon(
                          onPressed: isDefault ? null : () {
                            ref.read(themeSettingProvider.notifier).update((s) => s.copyWith(primaryColor: defaultPrimaryColor));
                          },
                          icon: const Icon(Icons.restart_alt, size: 16),
                          label: Text(l10n.defaultLabel, style: const TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: _HueSlider(),
                ),
              ),
              ListItem.switchItem(
                leading: const Icon(Icons.featured_video_outlined),
                title: Text(l10n.noTextMode),
                subtitle: Text(l10n.noTextModeDesc),
                delegate: SwitchDelegate(
                  value: appSettings.noTextMode,
                  onChanged: (v) {
                    ref.read(appSettingProvider.notifier).update(
                          (s) => s.copyWith(noTextMode: v),
                        );
                  },
                ),
              ),
            ],
          ),

          // App Settings
          ...generateSection(
            title: l10n.application,
            separated: false,
            items: [
              ListItem(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: _buildLanguageChips(context, appSettings.locale, ref),
              ),
              ListItem(
                leading: const Icon(Icons.folder),
                title: Text(l10n.defaultSavePath),
                subtitle: Text(formatPathForDisplay(
                  appSettings.defaultSavePath.isEmpty ? _defaultDownloadPath() : appSettings.defaultSavePath,
                  storageLabel: l10n.storageFolder,
                )),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (appSettings.defaultSavePath.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.restart_alt, size: 18),
                        tooltip: l10n.reset,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          ref.read(appSettingProvider.notifier).update(
                                (s) => s.copyWith(defaultSavePath: ''),
                              );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      tooltip: l10n.open,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        final path = appSettings.defaultSavePath.isEmpty ? _defaultDownloadPath() : appSettings.defaultSavePath;
                        globalState.openFolder(path);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.folder_open, size: 18),
                      tooltip: l10n.selectFolder,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _pickSavePath(ref),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // About
          ...generateSection(
            title: l10n.about,
            separated: false,
            items: [
              GestureDetector(
                onLongPressStart: (_) => _startResetLongPress(),
                onLongPressEnd: (_) => _cancelResetLongPress(),
                onLongPressCancel: () => _cancelResetLongPress(),
                child: Builder(builder: (context) {
                  final alpha = (_resetProgress * 80).clamp(0.0, 80.0).toInt();
                  return Container(
                    color: _resetPressing ? Colors.red.withAlpha(alpha) : Colors.transparent,
                    child: ListItem(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _showResetUI
                          ? const Icon(Icons.restart_alt, color: Colors.red)
                          : Image.asset('assets/images/icon.png', width: 24, height: 24),
                    ),
                    title: _showResetUI
                        ? Text(l10n.resetAllSettings, style: const TextStyle(color: Colors.red))
                        : Text(l10n.appVersion),
                    subtitle: _showResetUI
                        ? null
                        : Text(_debugMode
                            ? '${globalState.packageInfo.version}+${globalState.packageInfo.buildNumber}'
                            : globalState.packageInfo.version),
                    trailing: _showResetUI
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.update, size: 18),
                                tooltip: l10n.checkUpdate,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _checkForUpdate(context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 18),
                                tooltip: l10n.open,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => globalState.openUrl('https://github.com/$repository'),
                              ),
                            ],
                          ),
                      onTap: () {
                        final now = DateTime.now();
                        if (_lastVersionTap != null &&
                            now.difference(_lastVersionTap!).inSeconds >= 3) {
                          _versionTaps = 0;
                        }
                        _lastVersionTap = now;
                        _versionTaps++;
                        if (_versionTaps >= 5) {
                          _versionTaps = 0;
                          _lastVersionTap = null;
                          setState(() => _debugMode = !_debugMode);
                          LogBuffer.debugMode = _debugMode;
                          if (_autoClearLog) LogBuffer.clear();
                          final dL10n = context.appLocalizations;
                          context.showSnackBar(_debugMode ? dL10n.debugModeOn : dL10n.debugModeOff);
                        } else if (_versionTaps >= 2) {
                          final remaining = 5 - _versionTaps;
                          final enable = !_debugMode;
                          context.showSnackBar(
                            context.appLocalizations.debugTapHint(remaining, enable: enable),
                          );
                        }
                      },
                    ),
                  );
                }),
              ),
              ListItem(
                leading: const Icon(Icons.link),
                title: Text(l10n.crocVersion),
                subtitle: Text(_crocVersion == 'unavailable' ? l10n.unavailable : _crocVersion),
              ),
              ListItem(
                leading: const Icon(Icons.favorite),
                title: Text(l10n.acknowledgments),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AcknowledgmentsPage()),
                  );
                },
              ),
              ListItem(
                leading: const Icon(Icons.tune),
                title: Text(l10n.updateChannel),
                subtitle: _buildUpdateChannelChips(
                  ref.watch(appSettingProvider.select((s) => s.updateChannel)), ref),
              ),
              ListItem.switchItem(
                leading: const Icon(Icons.update_disabled),
                title: Text(l10n.autoCheckUpdate),
                delegate: SwitchDelegate(
                  value: ref.watch(appSettingProvider.select((s) => s.autoCheckUpdate)),
                  onChanged: (v) {
                    ref.read(appSettingProvider.notifier).update((s) => s.copyWith(autoCheckUpdate: v));
                  },
                ),
              ),
            ],
          ),

          // ── Debug section (visible when debug mode is active) ──
          if (_debugMode)
            ...generateSection(
              title: l10n.debug,
              separated: false,
              items: [
                ListItem(
                  leading: const Icon(Icons.bug_report),
                  title: Text(l10n.debugLog),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _LogViewerPage()),
                    );
                  },
                ),
                ListItem(
                  leading: const Icon(Icons.auto_delete),
                  title: Text(l10n.autoClearLog),
                  subtitle: Text(l10n.autoClearLogDesc),
                  trailing: Switch(
                    value: _autoClearLog,
                    onChanged: (v) => setState(() => _autoClearLog = v),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Language variant support ──
  // Group locales by language code; each entry is (displayName, localeString).
  // Tapping a selected language cycles through its variants.
  static final List<({String label, String locale})> _langVariants = [
    (label: 'English (United States)', locale: 'en'),
    (label: 'Français (France)', locale: 'fr'),
    (label: '中文 (简体)', locale: 'zh'),
    (label: '中文 (繁體)', locale: 'zh-Hant'),
    (label: '日本語 (日本)', locale: 'ja'),
  ];

  /// Base language group names (shown on first selection).
  static const _langGroupNames = <String, String>{
    'en': 'English',
    'fr': 'Français',
    'zh': '中文',
    'ja': '日本語',
  };

  Widget _buildLanguageChips(
      BuildContext context, String? currentLocale, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final selectedKey = currentLocale ?? 'auto';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: Text(l10n.autoLanguage),
            selected: selectedKey == 'auto',
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(locale: null),
                    );
              }
            },
          ),
          for (final group in const ['en', 'fr', 'zh', 'ja'])
            () {
              final variants = _langVariants.where((v) => v.locale.split('-').first == group).toList();
              final hasVariants = variants.length > 1;
              return ChoiceChip(
                label: Text(() {
                  if (selectedKey.split('-').first != group) {
                    return _langGroupNames[group]!;
                  }
                  if (!hasVariants) return _langGroupNames[group]!;
                  final v = _langVariants.firstWhere((v) => v.locale == selectedKey);
                  return v.label;
                }()),
                selected: selectedKey.split('-').first == group,
                onSelected: (v) {
                  if (!v) return;
                  final current = currentLocale;
                  final sameGroup = current != null && current.split('-').first == group;
                  if (!sameGroup) {
                    final first = variants.first.locale;
                    ref.read(appSettingProvider.notifier).update((s) => s.copyWith(locale: first));
                    setState(() {});
                    return;
                  }
                  if (!hasVariants) return;
                  // Cycle to next variant
                  final idx = variants.indexWhere((v2) => v2.locale == current);
                  final next = variants[(idx + 1) % variants.length].locale;
                  ref.read(appSettingProvider.notifier).update((s) => s.copyWith(locale: next));
                  setState(() {});
                  final label = variants.firstWhere((v2) => v2.locale == next).label;
                  if (context.mounted) context.showSnackBar(label);
                },
              );
            }(),
        ],
      ),
    );
  }

  Widget _buildRelayChips(RelayType current, WidgetRef ref) {
    final l10n = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: RelayType.values.map((type) {
          final selected = type == current;
          final label = switch (type) {
            RelayType.defaultRelay => l10n.defaultRelay,
            RelayType.customRelay => l10n.customRelay,
            RelayType.noRelay => l10n.noRelay,
          };
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(
                        relayConfig: s.relayConfig.copyWith(type: type),
                      ),
                    );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelayField({required IconData icon, required String hint, required TextEditingController controller, Widget? suffix, required ValueChanged<String> onChanged}) {
    return ListItem(
      minVerticalPadding: 4,
      leading: Icon(icon),
      title: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: suffix ?? const SizedBox(width: 0, height: 0),
        ),
        style: context.textTheme.bodyLarge,
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField({required String hint, required TextEditingController controller, required ValueChanged<String> onChanged}) {
    var obscured = true;
    return StatefulBuilder(
      builder: (_, setLocal) {
        return ListItem(
          minVerticalPadding: 4,
          leading: const Icon(Icons.lock),
          title: TextField(
            obscureText: obscured,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: IconButton(
                icon: Icon(obscured ? Icons.visibility : Icons.visibility_off, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => setLocal(() => obscured = !obscured),
              ),
            ),
            style: context.textTheme.bodyLarge,
            controller: controller,
            onChanged: onChanged,
          ),
        );
      },
    );
  }

  Widget _buildThemeModeChips(ThemeModeOption current, WidgetRef ref) {
    final l10n = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: ThemeModeOption.values.map((mode) {
          final selected = mode == current;
          return ChoiceChip(
            label: Text(mode == ThemeModeOption.light
                ? l10n.light
                : mode == ThemeModeOption.dark
                    ? l10n.dark
                    : l10n.system),
            selected: selected,
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(themeMode: mode),
                    );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpdateChannelChips(UpdateChannel current, WidgetRef ref) {
    final l10n = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: UpdateChannel.values.map((ch) {
          final selected = ch == current;
          return ChoiceChip(
            label: Text(ch == UpdateChannel.nightly
                ? l10n.nightlyChannel
                : l10n.releaseChannel),
            selected: selected,
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(updateChannel: ch),
                    );
              }
            },
          );
        }).toList(),
      ),
    );
  }

}

/// Hue slider bar — replaces the 6-preset + custom chip palette.
/// Dragging the hue updates the seed color in real time.
class _HueSlider extends ConsumerStatefulWidget {
  const _HueSlider();

  @override
  ConsumerState<_HueSlider> createState() => _HueSliderState();
}

class _HueSliderState extends ConsumerState<_HueSlider> {
  double _dragHue = 0;
  bool _isDragging = false;
  final _hexCtrl = TextEditingController();
  final _hexFocus = FocusNode();

  static const _rainbow = [
    Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00),
    Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000),
  ];

  @override
  void dispose() {
    _hexCtrl.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d, double width) {
    final dx = (d.localPosition.dx).clamp(0.0, width);
    _dragHue = dx / width * 360;
    _commit();
  }

  void _onTapUp(TapUpDetails d, double width) {
    _dragHue = d.localPosition.dx.clamp(0.0, width) / width * 360;
    _commit();
  }

  void _commit() {
    final seed = HSVColor.fromAHSV(1, _dragHue, 0.5, 1.0).toColor().toARGB32();
    ref.read(themeSettingProvider.notifier).update((s) => s.copyWith(primaryColor: seed));
  }

  void _onHexSubmit(String value) {
    final hex = value.replaceFirst('#', '').trim();
    if (hex.length != 6) return;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return;
    ref.read(themeSettingProvider.notifier).update((s) => s.copyWith(primaryColor: 0xFF000000 | parsed));
    _hexFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeSettingProvider.select((s) => s.primaryColor));
    if (!_isDragging) {
      _dragHue = HSVColor.fromColor(Color(current)).hue;
    }

    final seedColor = HSVColor.fromAHSV(1, _dragHue, 0.5, 1.0).toColor();
    final hex = '#${seedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    // Only update hex field when not focused (user isn't typing)
    if (!_hexFocus.hasFocus) {
      _hexCtrl.text = hex;
    }

    return Row(
      children: [
        // Hue bar — capped at 400px
        Flexible(
          child: SizedBox(
            width: 400,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onTapUp: (d) => _onTapUp(d, width),
                  onPanStart: (_) => _isDragging = true,
                  onPanUpdate: (d) => _onPanUpdate(d, width),
                  onPanEnd: (_) => _isDragging = false,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: _rainbow),
                    ),
                    child: Align(
                      alignment: Alignment(-1 + _dragHue / 180, 0),
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: seedColor,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Hex input
        SizedBox(
          width: 100,
          child: TextField(
            controller: _hexCtrl,
            focusNode: _hexFocus,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(),
              prefixText: '#',
              prefixStyle: TextStyle(fontSize: 13, fontFamily: 'monospace', color: Colors.grey),
            ),
            onSubmitted: _onHexSubmit,
          ),
        ),
      ],
    );
  }
}

/// Simple log viewer — displays LogBuffer contents.
class _LogViewerPage extends StatefulWidget {
  const _LogViewerPage();

  @override
  State<_LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<_LogViewerPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _exportLogs(List<String> logs, AppLocalizations l10n) async {
    final timestamp = DateFormat('yyMMdd-HHmmss').format(DateTime.now());
    final dir = Directory(AppPaths.savePathSync);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}FlCroc-debug-$timestamp.log');
    await file.writeAsString(logs.join('\n'));
    if (mounted) context.showSnackBar(l10n.logExported(formatPathForDisplay(file.path, storageLabel: l10n.storageFolder)));
  }

  @override
  Widget build(BuildContext context) {
    final logs = LogBuffer.logs;
    final l10n = context.appLocalizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debugLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.exportLog,
            onPressed: logs.isEmpty ? null : () => _exportLogs(logs, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: l10n.clear,
            onPressed: () {
              LogBuffer.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isWindows || isLinux) const WindowTitleBar(),
          Expanded(
            child: logs.isEmpty
                ? Center(child: Text(l10n.noLogs, style: context.textTheme.bodyMedium))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: SelectableText(
                        logs[i],
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
