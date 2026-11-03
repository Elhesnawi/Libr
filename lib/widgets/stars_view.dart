import 'package:flutter/material.dart';

/// نجوم للعرض فقط (تُقرَّب القيمة لأقرب نجمة).
class StarsView extends StatelessWidget {
  const StarsView({super.key, required this.value, this.size = 14});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = value.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= filled ? Icons.star : Icons.star_border,
            size: size,
            color: Colors.amber.shade700,
          ),
      ],
    );
  }
}
