import 'package:flutter/material.dart';

/// بطاقة هادئة اللون تُستعمل في قوائم الإدارة.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: child,
    );
  }
}
