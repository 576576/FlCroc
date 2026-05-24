import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const StyledText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: textAlign);
  }
}

class FadeScaleBox extends StatefulWidget {
  final Widget child;
  final Alignment alignment;

  const FadeScaleBox({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  State<FadeScaleBox> createState() => _FadeScaleBoxState();
}

class _FadeScaleBoxState extends State<FadeScaleBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        alignment: widget.alignment,
        child: widget.child,
      ),
    );
  }
}
