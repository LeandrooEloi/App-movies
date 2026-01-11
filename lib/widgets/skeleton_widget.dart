import 'package:flutter/material.dart';

class SkeletonWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const SkeletonWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFF2A2A2F);
    final highlight = const Color(0xFF3A3A40);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final color = Color.lerp(base, highlight, t)!;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}
