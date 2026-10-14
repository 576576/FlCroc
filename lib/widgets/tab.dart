import 'package:material_ui/material_ui.dart';

class const CustomTabBar({
  super.key,
  required this.tabs,
  required this.selectedIndex,
  required this.onChanged,
}) extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: tabs.map((t) => Tab(text: t)).toList(),
      onTap: onChanged,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
    );
  }
}
