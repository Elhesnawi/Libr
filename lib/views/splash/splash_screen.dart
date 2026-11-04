import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/root_gate.dart';
import 'package:librarry_app/views/splash/splash_cubit.dart';
import 'package:librarry_app/views/splash/splash_state.dart';
import 'package:librarry_app/widgets/app_logo.dart';

/// شاشة البداية: شعار هيئة الرقابة الإدارية، دولة ليبيا، ثم المكتبة الذكية.
/// تنتقل تلقائياً بعد ثوانٍ، أو بالضغط عليها.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (previous, current) => current.finished && !previous.finished,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (_, __, ___) => const RootGate(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Scaffold(
        body: InkWell(
          onTap: context.read<SplashCubit>().skip,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: const AppLogo(height: 110),
                ),
                const SizedBox(height: 28),
                Text(
                  'دولة ليبيا',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'المكتبة الذكية',
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 140,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: SplashCubit.duration,
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: value, minHeight: 4),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'اضغط للمتابعة',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
