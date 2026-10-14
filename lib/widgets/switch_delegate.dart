import 'package:material_ui/material_ui.dart';

class SwitchDelegate {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchDelegate({required this.value, required this.onChanged});
}
