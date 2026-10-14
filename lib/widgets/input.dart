import 'package:fl_croc/widgets/dialog.dart';
import 'package:material_ui/material_ui.dart';

class const OptionsDialog<T>({
  super.key,
  required this.title,
  required this.options,
  required this.textBuilder,
  required this.value,
  required this.onChanged,
}) extends StatelessWidget {
  final String title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: RadioGroup<T>(
        groupValue: value,
        onChanged: (v) {
          if (v != null) {
            onChanged(v);
            Navigator.pop(context);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<T>(
              title: Text(textBuilder(option)),
              value: option,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class const OptionItem<T>({
  required this.value,
  required this.label,
  this.icon,
}) {
  final T value;
  final String label;
  final IconData? icon;
}
