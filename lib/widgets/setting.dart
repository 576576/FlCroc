import 'package:fl_croc/common/iterable.dart';
import 'package:flutter/material.dart';

List<Widget> generateSection({
  required String title,
  required List<Widget> items,
  bool separated = true,
  Color? titleColor,
}) {
  return [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.blue,
        ),
      ),
    ),
    if (separated)
      ...items.separated(const Divider(height: 0, indent: 16))
    else
      ...items,
  ];
}

Widget generateListView(List<Widget> items) {
  return ListView.separated(
    itemBuilder: (_, index) => items[index],
    separatorBuilder: (_, _) => const Divider(height: 0),
    itemCount: items.length,
  );
}
