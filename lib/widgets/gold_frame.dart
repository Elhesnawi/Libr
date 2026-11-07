import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:librarry_app/core/brand.dart';

/// إطار ذهبي متحرك: حدّ بتدرج ذهبي يدور حول المحتوى مع وهج خفيف.
/// يتوقف الدوران تلقائياً إذا فعّل المستخدم «تقليل الحركة» في جهازه.
class GoldFrame extends StatefulWidget {
  const GoldFrame({super.key, required this.child});

  final Widget child;

  @override
  State<GoldFrame> createState() => _GoldFrameState();
}

class _GoldFrameState extends State<GoldFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return AnimatedBuilder(
      animation: _controller,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: widget.child,
      ),
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: SweepGradient(
            transform: GradientRotation(_controller.value * 2 * math.pi),
            colors: const [
              Brand.goldDeep,
              Brand.goldLight,
              Brand.goldCream,
              Brand.goldLight,
              Brand.goldDeep,
              Brand.gold,
              Brand.goldDeep,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Brand.gold.withValues(alpha: 0.35),
              blurRadius: 22,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
