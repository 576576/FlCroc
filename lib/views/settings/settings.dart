import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
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
  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingProvider);

    return BaseScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          // Relay Settings
          ...generateSection(
            title: 'Relay Settings',
            items: [
              ListItem.open(
                leading: const Icon(Icons.dns),
                title: const Text('Relay Type'),
                subtitle: Text(
                  appSettings.relayConfig.type == RelayType.defaultRelay
                      ? 'Default Relay'
                      : 'Custom Relay',
                ),
                delegate: OpenDelegate(
                  widget: OptionsDialog<RelayType>(
                    title: 'Relay Type',
                    options: RelayType.values,
                    value: appSettings.relayConfig.type,
                    textBuilder: (v) =>
                        v == RelayType.defaultRelay ? 'Default Relay' : 'Custom Relay',
                    onChanged: (v) {
                      ref.read(appSettingProvider.notifier).update(
                            (s) => s.copyWith(
                              relayConfig: s.relayConfig.copyWith(type: v),
                            ),
                          );
                    },
                  ),
                ),
              ),
              if (appSettings.relayConfig.type == RelayType.customRelay) ...[
                const Divider(height: 0, indent: 56),
                ListItem(
                  leading: const Icon(Icons.link),
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Relay Address',
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
            title: 'Theme',
            items: [
              ListItem.open(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme Mode'),
                subtitle: Text(appSettings.themeMode.name),
                delegate: OpenDelegate(
                  widget: OptionsDialog<ThemeModeOption>(
                    title: 'Theme Mode',
                    options: ThemeModeOption.values,
                    value: appSettings.themeMode,
                    textBuilder: (v) => v.name,
                    onChanged: (v) {
                      ref.read(appSettingProvider.notifier).update(
                            (s) => s.copyWith(themeMode: v),
                          );
                    },
                  ),
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Pure Black Mode'),
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
            title: 'Application',
            items: [
              ListItem.open(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(
                  appSettings.locale == 'zh' ? '中文' : 'English',
                ),
                delegate: OpenDelegate(
                  widget: OptionsDialog<String>(
                    title: 'Language',
                    options: const ['en', 'zh'],
                    value: appSettings.locale ?? 'en',
                    textBuilder: (v) => v == 'zh' ? '中文' : 'English',
                    onChanged: (v) {
                      ref.read(appSettingProvider.notifier).update(
                            (s) => s.copyWith(locale: v),
                          );
                    },
                  ),
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.update),
                title: const Text('Auto Check Update'),
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
            title: 'About',
            items: [
              ListItem(
                leading: const Icon(Icons.info),
                title: const Text('FlCroc'),
                subtitle: Text('v${globalState.packageInfo.version}'),
              ),
              const Divider(height: 0, indent: 56),
              ListItem(
                leading: const Icon(Icons.description),
                title: const Text('Description'),
                subtitle: const Text(
                  'A cross-platform file transfer GUI client powered by croc.',
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem(
                leading: const Icon(Icons.code),
                title: const Text('Check Update'),
                onTap: () {
                  globalState.openUrl(
                    'https://github.com/schollz/croc/releases',
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
}
