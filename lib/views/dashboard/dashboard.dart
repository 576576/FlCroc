import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/widgets.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final _isEditNotifier = ValueNotifier<bool>(false);

  List<GridItem> _buildDashboardWidgets(AppSettingProps settings) {
    final widgetMap = <DashboardWidget, GridItem>{
      DashboardWidget.transferSpeed: GridItem(
        crossAxisCellCount: 4,
        child: const TransferSpeedWidget(),
      ),
      DashboardWidget.totalTransferred: GridItem(
        crossAxisCellCount: 4,
        child: const TotalTransferredWidget(),
      ),
      DashboardWidget.quickSend: GridItem(
        crossAxisCellCount: 4,
        child: const QuickSendWidget(),
      ),
      DashboardWidget.recentTransfers: GridItem(
        crossAxisCellCount: 4,
        child: const RecentTransfersWidget(),
      ),
      DashboardWidget.crocStatus: GridItem(
        crossAxisCellCount: 4,
        child: const CrocStatusWidget(),
      ),
    };

    return settings.dashboardWidgets
        .map((w) => widgetMap[w])
        .where((item) => item != null)
        .cast<GridItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);

    return CommonScaffold(
      title: 'Dashboard',
      actions: [
        ValueListenableBuilder(
          valueListenable: _isEditNotifier,
          builder: (_, isEdit, __) {
            return IconButton(
              onPressed: () {
                _isEditNotifier.value = !isEdit;
              },
              icon: Icon(isEdit ? Icons.check : Icons.edit),
            );
          },
        ),
      ],
      body: SingleChildScrollView(
        child: SuperGrid(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _buildDashboardWidgets(settings),
        ),
      ),
    );
  }
}
