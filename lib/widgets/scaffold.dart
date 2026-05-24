import 'package:fl_croc/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CommonScaffold extends StatefulWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;

  const CommonScaffold({
    super.key,
    this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.appBar,
  });

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  final _isFabExtendedNotifier = ValueNotifier<bool>(true);

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      title: widget.title != null ? Text(widget.title!) : null,
      actions: widget.actions,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ?? _buildDefaultAppBar(),
      body: NotificationListener<UserScrollNotification>(
        child: widget.body,
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            _isFabExtendedNotifier.value = false;
          } else if (notification.direction == ScrollDirection.forward) {
            _isFabExtendedNotifier.value = true;
          }
          return false;
        },
      ),
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      backgroundColor: widget.backgroundColor,
      floatingActionButton: widget.floatingActionButton != null
          ? ValueListenableBuilder<bool>(
              valueListenable: _isFabExtendedNotifier,
              builder: (_, isExtended, child) {
                return AnimatedScale(
                  scale: isExtended ? 1.0 : 0.0,
                  duration: commonDuration,
                  child: child,
                );
              },
              child: widget.floatingActionButton,
            )
          : null,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

class BaseScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.title,
    this.actions = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(body: body, title: title, actions: actions);
  }
}

class CommonScaffoldFabExtendedProvider extends InheritedWidget {
  final bool isExtended;

  const CommonScaffoldFabExtendedProvider({
    super.key,
    required this.isExtended,
    required super.child,
  });

  @override
  bool updateShouldNotify(
      CommonScaffoldFabExtendedProvider oldWidget) {
    return isExtended != oldWidget.isExtended;
  }

  static bool of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<
            CommonScaffoldFabExtendedProvider>();
    return widget?.isExtended ?? true;
  }
}
