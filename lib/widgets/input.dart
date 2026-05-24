import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/widgets/dialog.dart';
import 'package:flutter/material.dart';

class OptionsDialog<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;
  final ValueChanged<T> onChanged;

  const OptionsDialog({
    super.key,
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return RadioListTile<T>(
            title: Text(textBuilder(option)),
            value: option,
            groupValue: value,
            onChanged: (v) {
              if (v != null) {
                onChanged(v);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class OptionItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const OptionItem({required this.value, required this.label, this.icon});
}
