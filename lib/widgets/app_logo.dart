import 'package:flutter/material.dart';

/// شعار هيئة الرقابة الإدارية (assets/images/logo.png).
/// الشعار عريض (نسبة تقارب 1.8 : 1) لذلك يُحدَّد الارتفاع ويُترك العرض تلقائياً.
/// وإن لم يوجد الملف تظهر أيقونة بديلة بدل أن يتعطل التطبيق.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.account_balance,
        size: height,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
