import 'dart:async';

import 'package:flutter/material.dart';
import 'package:librarry_app/widgets/app_logo.dart';

/// شاشة التحميل: شعار الهيئة مع مؤشر تقدّم.
class LoadingSplash extends StatelessWidget {
  const LoadingSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: const AppLogo(height: 80),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(minHeight: 4),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'جارٍ التحميل',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// ينفّذ [action] وفوقه شاشة التحميل بشعار الهيئة، ثم يغلقها.
/// تبقى الشاشة ظاهرة [ms] ملّي ثانية على الأقل حتى لا تومض.
/// وإن رمى [action] استثناءً يُغلق التحميل أولاً ثم يُعاد رمي الاستثناء.
Future<T> withSplash<T>(
  BuildContext context,
  FutureOr<T> Function() action, {
  int ms = 700,
}) async {
  final nav = Navigator.of(context, rootNavigator: true);
  final started = DateTime.now();

  unawaited(
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => const PopScope(
        canPop: false,
        child: LoadingSplash(),
      ),
    ),
  );

  T? value;
  Object? error;
  StackTrace? stack;
  try {
    value = await action();
  } catch (e, s) {
    error = e;
    stack = s;
  }

  final elapsed = DateTime.now().difference(started).inMilliseconds;
  if (elapsed < ms) {
    await Future<void>.delayed(Duration(milliseconds: ms - elapsed));
  }
  nav.pop();

  if (error != null) {
    Error.throwWithStackTrace(error, stack!);
  }
  return value as T;
}
