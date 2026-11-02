import 'package:flutter/material.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/splash/splash_screen.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  static const Color _seed = Color(0xFF1F5FA6);

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'المكتبة الذكية',
        themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
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
    );
  }
}
