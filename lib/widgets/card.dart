import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/models/models.dart';
import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  final Info? info;
  final Widget child;
  final Widget? leading;
  final VoidCallback? onPressed;
  final CommonCardType type;
  final double radius;
  final EdgeInsetsGeometry? padding;

  const CommonCard({
    super.key,
    this.info,
    required this.child,
    this.leading,
    this.onPressed,
    this.type = CommonCardType.outlined,
    this.radius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: type == CommonCardType.filled ? 0 : 1,
      color: type == CommonCardType.filled
          ? context.colorScheme.surfaceContainerHighest
          : context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: type == CommonCardType.outlined
            ? BorderSide(color: context.colorScheme.outlineVariant)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (info != null) _buildInfo(context),
              child,
            ],
          ),
        ),
      ),
    );
    return card;
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          leading ?? Icon(info!.iconData, size: 20),
          const SizedBox(width: 8),
          Text(
            info!.label,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

enum CommonCardType { filled, outlined }
