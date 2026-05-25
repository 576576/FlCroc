import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';

class QuickReceiveWidget extends StatelessWidget {
  const QuickReceiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return SizedBox(
      height: 120,
      child: CommonCard(
        info: Info(iconData: Icons.download, label: l10n.quickReceive),
        child: Center(
          child: FilledButton.icon(
            onPressed: () {
              appController.navigateTo(PageLabel.receive);
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.receive),
          ),
        ),
      ),
    );
  }
}
