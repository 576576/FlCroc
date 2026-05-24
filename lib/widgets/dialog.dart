import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonDialog extends ConsumerWidget {
  final String title;
  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsets? padding;

  const CommonDialog({
    super.key,
    required this.title,
    this.actions,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      title: Text(title),
      actions: actions,
      contentPadding: padding,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: min(size.height - 40, 500),
          maxWidth: 300,
        ),
        width: size.width - 40,
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
