import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';

class QuickSendWidget extends StatelessWidget {
  const QuickSendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CommonCard(
        info: const Info(iconData: Icons.upload_file, label: 'Quick Send'),
        child: Center(
          child: FilledButton.icon(
            onPressed: () {
              // handled by page navigation
            },
            icon: const Icon(Icons.add),
            label: const Text('Send Files'),
          ),
        ),
      ),
    );
  }
}
