import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  static const _palettes = <List<Color>>[
    [Color(0xFF6750A4), Color(0xFF625B71)], // M3 default
    [Color(0xFF1B6EF3), Color(0xFF004AAD)], // Blue
    [Color(0xFF00BFA5), Color(0xFF00796B)], // Teal
    [Color(0xFFE91E63), Color(0xFFAD1457)], // Pink
    [Color(0xFFFF6F00), Color(0xFFBF360C)], // Orange
    [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Green
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.appLocalizations;
    final appSettings = ref.watch(appSettingProvider);
    final themeProps = ref.watch(themeSettingProvider);
    final cs = context.colorScheme;
    final tt = context.textTheme;

    return BaseScaffold(
      title: l10n.theme,
      body: ListView(
        children: [
          ..._section(cs, tt, l10n.themeMode, Icons.brightness_6, [
            _themeModeChips(context, appSettings.themeMode, ref),
          ]),
          const Divider(),
          ..._section(cs, tt, l10n.pureBlackMode, Icons.dark_mode, [
            ListItem.switchItem(
              leading: const Icon(Icons.dark_mode),
              title: Text(l10n.pureBlackMode),
              delegate: SwitchDelegate(
                value: appSettings.pureBlackMode,
                onChanged: (v) => ref.read(appSettingProvider.notifier).update((s) => s.copyWith(pureBlackMode: v)),
              ),
            ),
          ]),
          const Divider(),
          ..._section(cs, tt, 'Color Palette', Icons.palette, [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(spacing: 12, runSpacing: 12, children: [
                for (final palette in _palettes)
                  _ColorPaletteChip(
                    colors: palette,
                    isSelected: Color(themeProps.primaryColor) == palette[0],
                    onTap: () => ref.read(themeSettingProvider.notifier).update((s) => s.copyWith(primaryColor: palette[0].value)),
                  ),
              ]),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static List<Widget> _section(ColorScheme cs, TextTheme tt, String title, IconData icon, List<Widget> children) => [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(title, style: tt.titleSmall?.copyWith(color: cs.primary)),
      ]),
    ),
    ...children,
  ];

  Widget _themeModeChips(BuildContext context, ThemeModeOption current, WidgetRef ref) {
    final l10n = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16),
      child: Wrap(spacing: 8, children: ThemeModeOption.values.map((mode) {
        return ChoiceChip(
          label: Text(mode == ThemeModeOption.light ? l10n.light : mode == ThemeModeOption.dark ? l10n.dark : l10n.system),
          selected: mode == current,
          onSelected: (v) {
            if (v) ref.read(appSettingProvider.notifier).update((s) => s.copyWith(themeMode: mode));
          },
        );
      }).toList()),
    );
  }
}

class _ColorPaletteChip extends StatelessWidget {
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorPaletteChip({required this.colors, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: context.colorScheme.primary, width: 3) : null,
          gradient: LinearGradient(colors: colors),
        ),
      ),
    );
  }
}
