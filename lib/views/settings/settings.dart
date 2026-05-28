import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/core/lib.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  String _crocVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadCrocVersion();
  }

  Future<void> _loadCrocVersion() async {
    try {
      final v = await coreController.getVersion();
      if (mounted) setState(() => _crocVersion = v);
    } catch (_) {
      if (mounted) setState(() => _crocVersion = 'unavailable');
    }
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
                  value: appSettings.relayConfig.address,
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
                  value: appSettings.relayConfig.port,
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
                  value: appSettings.relayConfig.password,
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
                leading: const Icon(Icons.palette),
                title: Text(l10n.colorPalette),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: _PaletteSection(),
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
              ListItem.switchItem(
                leading: const Icon(Icons.update),
                title: Text(l10n.checkUpdate),
                delegate: SwitchDelegate(
                  value: appSettings.autoCheckUpdate,
                  onChanged: (v) {
                    ref.read(appSettingProvider.notifier).update(
                          (s) => s.copyWith(autoCheckUpdate: v),
                        );
                  },
                ),
              ),
            ],
          ),

          // About
          ...generateSection(
            title: l10n.about,
            separated: false,
            items: [
              ListItem(
                leading: const Icon(Icons.info),
                title: Text(l10n.appVersion),
                subtitle: Text(globalState.packageInfo.version),
              ),
              ListItem(
                leading: const Icon(Icons.link),
                title: Text(l10n.crocVersion),
                subtitle: Text(_crocVersion == 'unavailable' ? l10n.unavailable : _crocVersion),
              ),
              ListItem(
                leading: const Icon(Icons.description),
                title: Text(l10n.description),
                subtitle: Text(l10n.desc),
              ),
              ListItem(
                leading: const Icon(Icons.code),
                title: Text(l10n.checkUpdate),
                onTap: () {
                  globalState.openUrl(
                    'https://github.com/$repository',
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

  Widget _buildRelayField({required IconData icon, required String hint, required String value, Widget? suffix, required ValueChanged<String> onChanged}) {
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
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField({required String hint, required String value, required ValueChanged<String> onChanged}) {
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
            controller: TextEditingController(text: value),
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

  static const _kPresetColors = <int>[
    0xFF6750A4, // M3 default
    0xFF1B6EF3, // Blue
    0xFF00BFA5, // Teal
    0xFFE91E63, // Pink
    0xFFFF6F00, // Orange
    0xFF4CAF50, // Green
  ];
}

/// Isolated palette section — rebuilds independently when primaryColor changes,
/// preventing the entire settings page from flickering.
class _PaletteSection extends ConsumerWidget {
  const _PaletteSection();

  static final _labels = <String Function(AppLocalizations)>[
    (l) => l.defaultLabel,
    (l) => l.colorBlue,
    (l) => l.colorTeal,
    (l) => l.colorPink,
    (l) => l.colorOrange,
    (l) => l.colorGreen,
  ];

  void _showColorPalette(BuildContext context, WidgetRef ref, int currentColor) {
    final hsv = HSVColor.fromColor(Color(currentColor));
    showDialog(
      context: context,
      builder: (ctx) => _ColorPaletteDialog(ref: ref, initialColor: hsv),
    ).then((result) {
      if (result != null && result is Color) {
        ref.read(themeSettingProvider.notifier).update((s) => s.copyWith(primaryColor: result.value));
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeSettingProvider.select((s) => s.primaryColor));
    final brightness = Theme.of(context).brightness;
    final l10n = context.appLocalizations;
    final isCustom = !_SettingsViewState._kPresetColors.contains(current) && current != defaultPrimaryColor;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < _SettingsViewState._kPresetColors.length; i++)
          _ColorChip(
            color: cachedColorScheme(_SettingsViewState._kPresetColors[i], brightness).primary,
            isSelected: current == _SettingsViewState._kPresetColors[i],
            onTap: () => ref.read(themeSettingProvider.notifier).update((s) => s.copyWith(primaryColor: _SettingsViewState._kPresetColors[i])),
            label: _labels[i](l10n),
          ),
        _ColorChip(
          color: cachedColorScheme(current, brightness).primary,
          isSelected: isCustom,
          onTap: () => _showColorPalette(context, ref, current),
          label: l10n.customLabel,
        ),
      ],
    );
  }
}

/// Simple HSL color palette dialog (FlClash-inspired).
class _ColorPaletteDialog extends StatefulWidget {
  final WidgetRef ref;
  final HSVColor initialColor;
  const _ColorPaletteDialog({required this.ref, required this.initialColor});

  @override
  State<_ColorPaletteDialog> createState() => _ColorPaletteDialogState();
}

class _ColorPaletteDialogState extends State<_ColorPaletteDialog> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    _hue = widget.initialColor.hue;
    _saturation = widget.initialColor.saturation;
    _value = widget.initialColor.value;
  }

  Color get _currentColor => HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return AlertDialog(
      title: Text(l10n.colorPalette),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 16),
            // Saturation / Value square
            GestureDetector(
              onPanDown: (d) => _updateSV(d.localPosition),
              onPanUpdate: (d) => _updateSV(d.localPosition),
              child: Container(
                width: 240, height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.white, HSVColor.fromAHSV(1, _hue, 1, 1).toColor()],
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Colors.black],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: _saturation * 240 - 8,
                      top: (1 - _value) * 160 - 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Hue slider
            Row(
              children: [
                const Icon(Icons.palette, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onPanDown: (d) => _updateHue(d.localPosition.dx, 224),
                    onPanUpdate: (d) => _updateHue(d.localPosition.dx, 224),
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00),
                            Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF), Color(0xFFFF0000),
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment(-1 + _hue / 180, 0),
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _currentColor, border: Border.all(color: Colors.white, width: 2)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // HEX display
            Text(
              '#${_currentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
              style: context.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _currentColor), child: Text(l10n.confirm)),
      ],
    );
  }

  void _updateSV(Offset local) {
    setState(() {
      _saturation = (local.dx / 240).clamp(0.0, 1.0);
      _value = (1 - local.dy / 160).clamp(0.0, 1.0);
    });
  }

  void _updateHue(double dx, double width) {
    setState(() {
      _hue = ((dx / width).clamp(0.0, 1.0) * 360) % 360;
    });
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChip({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: color,
      selectedColor: color,
      checkmarkColor: textColor,
      side: isSelected ? BorderSide(color: textColor, width: 2) : BorderSide(color: Colors.transparent),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
