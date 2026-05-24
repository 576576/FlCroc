import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/views/views.dart';
import 'package:flutter/material.dart';

class Navigation {
  static Navigation? _instance;

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }

  Navigation._internal();

  List<NavigationItem> getItems() {
    return [
      NavigationItem(
        icon: const Icon(Icons.space_dashboard),
        label: PageLabel.dashboard,
        builder: (_) => const DashboardView(
          key: GlobalObjectKey(PageLabel.dashboard),
        ),
      ),
      NavigationItem(
        icon: const Icon(Icons.upload_file),
        label: PageLabel.send,
        builder: (_) => const SendView(key: GlobalObjectKey(PageLabel.send)),
      ),
      NavigationItem(
        icon: const Icon(Icons.download),
        label: PageLabel.receive,
        builder: (_) =>
            const ReceiveView(key: GlobalObjectKey(PageLabel.receive)),
      ),
      NavigationItem(
        icon: const Icon(Icons.history),
        label: PageLabel.history,
        builder: (_) =>
            const HistoryView(key: GlobalObjectKey(PageLabel.history)),
      ),
      NavigationItem(
        icon: const Icon(Icons.settings),
        label: PageLabel.settings,
        builder: (_) =>
            const SettingsView(key: GlobalObjectKey(PageLabel.settings)),
      ),
    ];
  }
}
