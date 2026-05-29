import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/state.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:fl_croc/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';

class AcknowledgmentsPage extends StatelessWidget {
  const AcknowledgmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final projects = [
      _Project(name: 'Flutter', description: l10n.flutterDesc, url: 'https://github.com/flutter/flutter'),
      _Project(name: 'croc', description: l10n.crocDesc, url: 'https://github.com/schollz/croc'),
      _Project(name: 'FlClash', description: l10n.flClashDesc, url: 'https://github.com/chen08209/FlClash'),
    ];
    final body = ListView.separated(
      itemCount: projects.length,
      separatorBuilder: (_, _) => const Divider(height: 0, indent: 72),
      itemBuilder: (_, index) {
        final p = projects[index];
        return ListTile(
          leading: const Icon(Icons.code),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(p.description),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            tooltip: l10n.open,
            onPressed: () => globalState.openUrl(p.url),
          ),
          onTap: () => globalState.openUrl(p.url),
        );
      },
    );

    if (isDesktop) {
      return Column(
        children: [
          const WindowTitleBar(),
          Expanded(
            child: BaseScaffold(title: l10n.openSourceProjects, body: body),
          ),
        ],
      );
    }
    return BaseScaffold(title: l10n.openSourceProjects, body: body);
  }
}

class _Project {
  final String name;
  final String description;
  final String url;
  const _Project({required this.name, required this.description, required this.url});
}
