import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  late final _relayAddrCtrl = TextEditingController();
  late final _relayPortCtrl = TextEditingController();
  late final _relayPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Delay version check until after core controller initializes (post first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCrocVersion());
    final relay = ref.read(appSettingProvider).relayConfig;
    _relayAddrCtrl.text = relay.address;
    _relayPortCtrl.text = relay.port;
    _relayPassCtrl.text = relay.password;
  }

  @override
  void dispose() {
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

    try {
      final client = HttpClient();
      try {
        final uri = Uri.https('api.github.com', '/repos/$repository/releases/latest');
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
        if (latestTag.isEmpty || latestTag == currentVer) {
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
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    globalState.openUrl('https://github.com/$repository/releases');
                  },
                  child: Text(l10n.update),
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
                  downloadsLabel: l10n.downloadsFolder,
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
              ListItem(
                leading: const Icon(Icons.restart_alt, color: Colors.red),
                title: Text(l10n.resetAllSettings, style: const TextStyle(color: Colors.red)),
                onTap: () => _resetAllSettings(context),
              ),
            ],
          ),

          // About
          ...generateSection(
            title: l10n.about,
            separated: false,
            items: [
              ListItem(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/icon.png', width: 24, height: 24),
                ),
                title: Text(l10n.appVersion),
                subtitle: Text(globalState.packageInfo.version),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  tooltip: l10n.open,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => globalState.openUrl('https://github.com/$repository'),
                ),
                onTap: () {
                  _versionTaps++;
                  if (_versionTaps >= 5) {
                    _versionTaps = 0;
                    setState(() => _debugMode = !_debugMode);
                    LogBuffer.debugMode = _debugMode;
                    final l10n = context.appLocalizations;
                    context.showSnackBar(_debugMode ? l10n.debugModeOn : l10n.debugModeOff);
                  }
                },
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
                leading: const Icon(Icons.update),
                title: Text(l10n.checkUpdate),
                onTap: () => _checkForUpdate(context),
              ),

              // Debug: log viewer
              if (_debugMode)
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
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLanguageChips(
      BuildContext context, String? currentLocale, WidgetRef ref) {
    final l10n = context.appLocalizations;
    // locale=null → auto (system), locale='en' → English, locale='zh' → 中文
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
          ChoiceChip(
            label: Text('English'),
            selected: selectedKey == 'en',
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(locale: 'en'),
                    );
              }
            },
          ),
          ChoiceChip(
            label: Text('中文'),
            selected: selectedKey == 'zh',
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(locale: 'zh'),
                    );
              }
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    final logs = LogBuffer.logs;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appLocalizations.debugLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: context.appLocalizations.clear,
            onPressed: () {
              LogBuffer.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('暂无日志'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  logs[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
    );
  }
}
