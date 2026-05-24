import 'package:flutter/material.dart';

class PopScopeWidget extends StatelessWidget {
  final Widget child;
  final bool canPop;

  const PopScopeWidget({
    super.key,
    required this.child,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: child,
    );
  }
}

extension SEPARATED on List<Widget> {
  List<Widget> separated(Widget separator) {
    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      if (i > 0) result.add(separator);
      result.add(this[i]);
    }
    return result;
  }
}
