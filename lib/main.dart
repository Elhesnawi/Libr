import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/services/theme_preference.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/auth/auth_state.dart';
import 'package:librarry_app/views/splash/splash_screen.dart';
import 'package:librarry_app/config/supabase_config.dart';
// نخفي AuthState الخاص بـ Supabase لأنه يتعارض مع AuthState الخاص بالتطبيق.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // الاتصال بـ Supabase قبل تشغيل التطبيق.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );

  // يسترجع الوضع الليلي المحفوظ قبل رسم أول شاشة.
  LibraryStore.instance.setDarkMode(await ThemePreference.load());
  runApp(const LibraryApp());
}

/// عميل Supabase للاستخدام في باقي الملفات.
final supabase = Supabase.instance.client;

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  static const Color _seed = Color(0xFF1F5FA6);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) => previous.darkMode != current.darkMode,
        builder: (context, auth) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'المكتبة الذكية',
          themeMode: auth.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: _seed,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: _seed,
            brightness: Brightness.dark,
          ),
          // يجعل الاتجاه من اليمين لليسار في كل الشاشات.
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
