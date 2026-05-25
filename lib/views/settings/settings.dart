import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/controller.dart';
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
  String _crocVersion = '';

  @override
  void initState() {
    super.initState();
    _loadCrocVersion();
  }

  Future<void> _loadCrocVersion() async {
    final v = await coreController.getVersion();
    if (mounted) setState(() => _crocVersion = v);
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
            items: [
              ListItem(
                leading: const Icon(Icons.dns),
                title: Text(l10n.relayType),
                subtitle: _buildRelayChips(appSettings.relayConfig.type, ref),
              ),
              if (appSettings.relayConfig.type == RelayType.customRelay) ...[
                const Divider(height: 0, indent: 56),
                ListItem(
                  leading: const Icon(Icons.link),
                  title: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.relayAddress,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: context.textTheme.bodyLarge,
                    controller: TextEditingController(
                      text: appSettings.relayConfig.address,
                    ),
                    onChanged: (v) {
                      ref.read(appSettingProvider.notifier).update(
                            (s) => s.copyWith(
                              relayConfig: s.relayConfig.copyWith(address: v),
                            ),
                          );
                    },
                  ),
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
                subtitle: Text(_crocVersion.isNotEmpty
                    ? _crocVersion
                    : l10n.loading),
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
          return ChoiceChip(
            label: Text(
              type == RelayType.defaultRelay ? l10n.defaultRelay : l10n.customRelay,
            ),
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
