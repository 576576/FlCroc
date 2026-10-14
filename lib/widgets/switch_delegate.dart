import 'package:material_ui/material_ui.dart';

class const SwitchDelegate({required this.value, required this.onChanged}) {
  final bool value;
  final ValueChanged<bool> onChanged;
}
