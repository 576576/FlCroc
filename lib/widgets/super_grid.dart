import 'dart:async';
import 'dart:math';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:flutter/material.dart';

class SuperGrid extends StatefulWidget {
  final List<GridItem> children;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int crossAxisCount;
  final VoidCallback? onUpdate;

  const SuperGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.onUpdate,
  });

  @override
  State<SuperGrid> createState() => SuperGridState();
}

class SuperGridState extends State<SuperGrid> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int effectiveCrossAxisCount = widget.crossAxisCount;
    if (width < 400) {
      effectiveCrossAxisCount = 2;
    } else if (width < 600) {
      effectiveCrossAxisCount = 3;
    } else if (width < 900) {
      effectiveCrossAxisCount = 4;
    } else {
      effectiveCrossAxisCount = 6;
    }

    final itemWidth =
        (width - (effectiveCrossAxisCount - 1) * widget.crossAxisSpacing - 32) /
            effectiveCrossAxisCount;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: widget.crossAxisSpacing,
        runSpacing: widget.mainAxisSpacing,
        children: widget.children.map((item) {
          final crossAxisCellCount = item.crossAxisCellCount.clamp(1, effectiveCrossAxisCount);
          final childWidth = itemWidth * crossAxisCellCount +
              widget.crossAxisSpacing * (crossAxisCellCount - 1);
          return SizedBox(
            width: childWidth,
            child: item.child,
          );
        }).toList(),
      ),
    );
  }

  double getWidgetHeight(int rows) {
    return 120.0 * rows;
  }
}
