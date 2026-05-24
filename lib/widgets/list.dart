import 'package:fl_croc/common/context.dart';
import 'package:fl_croc/common/navigator.dart';
import 'package:fl_croc/widgets/switch_delegate.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final double? minVerticalPadding;

  const ListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.minVerticalPadding,
  });

  static Widget switchItem({
    Key? key,
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    required SwitchDelegate delegate,
    EdgeInsetsGeometry? padding,
    double? minVerticalPadding,
  }) {
    return _SwitchListItem(
      key: key,
      leading: leading,
      title: title,
      subtitle: subtitle,
      delegate: delegate,
      padding: padding,
      minVerticalPadding: minVerticalPadding,
    );
  }

  static Widget open({
    Key? key,
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    required OpenDelegate delegate,
    EdgeInsetsGeometry? padding,
    double? minVerticalPadding,
  }) {
    return _OpenListItem(
      key: key,
      leading: leading,
      title: title,
      subtitle: subtitle,
      delegate: delegate,
      padding: padding,
      minVerticalPadding: minVerticalPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: minVerticalPadding ?? 12,
        );
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: effectivePadding,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyLarge ?? const TextStyle(),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ) ?? const TextStyle(),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SwitchListItem extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final SwitchDelegate delegate;
  final EdgeInsetsGeometry? padding;
  final double? minVerticalPadding;

  const _SwitchListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.delegate,
    this.padding,
    this.minVerticalPadding,
  });

  @override
  State<_SwitchListItem> createState() => _SwitchListItemState();
}

class _SwitchListItemState extends State<_SwitchListItem> {
  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      padding: widget.padding,
      minVerticalPadding: widget.minVerticalPadding,
      onTap: () {
        widget.delegate.onChanged(!widget.delegate.value);
      },
      trailing: Switch(
        value: widget.delegate.value,
        onChanged: widget.delegate.onChanged,
      ),
    );
  }
}

class _OpenListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final OpenDelegate delegate;
  final EdgeInsetsGeometry? padding;
  final double? minVerticalPadding;

  const _OpenListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.delegate,
    this.padding,
    this.minVerticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: leading,
      title: title,
      subtitle: subtitle,
      padding: padding,
      minVerticalPadding: minVerticalPadding,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        BaseNavigator.push(context, delegate.widget);
      },
    );
  }
}

class OpenDelegate {
  final Widget widget;
  const OpenDelegate({required this.widget});
}
