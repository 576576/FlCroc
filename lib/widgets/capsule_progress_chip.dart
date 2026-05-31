import 'dart:ui';

import 'package:flutter/material.dart';

/// A status chip with a capsule-shaped progress border.
class CapsuleProgressChip extends StatelessWidget {
  const CapsuleProgressChip({
    super.key,
    required this.label,
    required this.color,
    this.progress = -1,
    this.animate = true,
  });

  final String label;
  final Color color;
  final double progress; // 0.0–1.0, or -1 for indeterminate
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    if (!animate || progress < 0) {
      return CustomPaint(
        painter: _CapsuleProgressPainter(
          progress: progress < 0 ? null : progress,
          color: color,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: borderRadius,
          ),
          child: Text(label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (_, value, __) {
        return CustomPaint(
          painter: _CapsuleProgressPainter(
            progress: value,
            color: color,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: borderRadius,
            ),
            child: Text(label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}

class _CapsuleProgressPainter extends CustomPainter {
  _CapsuleProgressPainter({this.progress, required this.color});

  final double? progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    paint.color = color.withValues(alpha: 0.15);
    canvas.drawRRect(rect, paint);

    paint.color = color;
    if (progress == null) {
      canvas.drawRRect(rect, paint);
    } else {
      final path = Path()..addRRect(rect);
      final metrics = path.computeMetrics().first;
      final totalLen = metrics.length;
      final drawLen = totalLen * progress!;
      if (drawLen > 0) {
        const startOffset = 0.28;
        final shift = totalLen * startOffset;
        final end = shift + drawLen;
        if (end <= totalLen) {
          canvas.drawPath(metrics.extractPath(shift, end), paint);
        } else {
          canvas.drawPath(metrics.extractPath(shift, totalLen), paint);
          canvas.drawPath(metrics.extractPath(0, end - totalLen), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CapsuleProgressPainter old) =>
      old.progress != progress || old.color != color;
}
