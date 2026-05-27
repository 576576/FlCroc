import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/lib.dart';
import 'package:fl_croc/enum/enum.dart';
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
  String _crocVersion = CoreLib.builtinCrocVersion;
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
            items: [
              ListItem(
                leading: const Icon(Icons.dns),
                title: Text(l10n.relayType),
                subtitle: _buildRelayChips(appSettings.relayConfig.type, ref),
              ),
              if (appSettings.relayConfig.type == RelayType.customRelay) ...[
                const Divider(height: 0, indent: 56),
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
                const Divider(height: 0, indent: 56),
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
                const Divider(height: 0, indent: 56),
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

          const Divider(),

          // Theme Settings
          ...generateSection(
            title: l10n.theme,
            items: [
              ListItem(
                leading: const Icon(Icons.brightness_6),
                title: Text(l10n.themeMode),
                subtitle: _buildThemeModeChips(appSettings.themeMode, ref),
              ),
              const Divider(height: 0, indent: 56),
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
          ),

          const Divider(),

          // App Settings
          ...generateSection(
            title: l10n.application,
            items: [
              ListItem(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: _buildLanguageChips(context, appSettings.locale, ref),
              ),
              const Divider(height: 0, indent: 56),
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

          const Divider(),

          // About
          ...generateSection(
            title: l10n.about,
            items: [
              ListItem(
                leading: const Icon(Icons.info),
                title: Text(l10n.appName),
                subtitle: Text('v${globalState.packageInfo.version}'),
              ),
              const Divider(height: 0, indent: 56),
              ListItem(
                leading: const Icon(Icons.link),
                title: Text(l10n.crocVersion),
                subtitle: Text(_crocVersion),
              ),
              const Divider(height: 0, indent: 56),
              ListItem(
                leading: const Icon(Icons.description),
                title: Text(l10n.description),
                subtitle: Text(l10n.desc),
              ),
              const Divider(height: 0, indent: 56),
              ListItem(
                leading: const Icon(Icons.code),
                title: Text(l10n.checkUpdate),
                onTap: () {
                  globalState.openUrl(
                    'https://github.com/576576/FlCroc',
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
    // locale=null → default (zh), locale='en' → English, locale='zh' → 中文
    final selectedKey = currentLocale ?? 'default';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('默认'),
            selected: selectedKey == 'default',
            onSelected: (v) {
              if (v) {
                ref.read(appSettingProvider.notifier).update(
                      (s) => s.copyWith(locale: null),
                    );
              }
            },
          ),
          ChoiceChip(
            label: const Text('English'),
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
            label: const Text('中文'),
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
}
