import 'package:flutter/material.dart';

class FilledButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  const FilledButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
      label: Text(text),
    );
  }
}
