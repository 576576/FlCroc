import 'package:material_ui/material_ui.dart';

class const PopScopeWidget({super.key, required this.child, this.canPop = true})
    extends StatelessWidget {
  final Widget child;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: canPop, child: child);
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
