import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:librarry_app/core/brand.dart';

/// زر ذهبي متحرك: تدرج ذهبي ينساب، ولمعة تعبر الزر، ووهج يتنفس حوله.
/// يتوقف التحريك تلقائياً إذا فعّل المستخدم «تقليل الحركة» في جهازه.
class GoldButton extends StatefulWidget {
  const GoldButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

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
    final radius = BorderRadius.circular(12);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // يتنفس الوهج: يقوى ويضعف مرة كل دورة.
        final glow = 0.30 + 0.30 * (0.5 - 0.5 * math.cos(2 * math.pi * t));
        return Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Brand.gold.withValues(alpha: glow),
                blurRadius: 14 + 10 * glow,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [Brand.gold, Brand.goldLight, Brand.gold],
                    tileMode: TileMode.mirror,
                    transform: _SlideGradient(t),
                  ),
                ),
                child: InkWell(
                  onTap: widget.onPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // اللمعة العابرة.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment(-1.8 + 3.6 * t, 0),
                            child: FractionallySizedBox(
                              widthFactor: 0.3,
                              heightFactor: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.6),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            color: Brand.onGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// يزيح التدرج أفقياً بنسبة [percent] من عرض الزر؛
/// مع TileMode.mirror تكون الحركة متصلة بلا قفزة عند كل دورة.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}
