import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/login/login_screen.dart';
import 'package:librarry_app/views/staff/staff_dashboard.dart';
import 'package:librarry_app/views/user/user_shell.dart';

/// يقرر الشاشة حسب الجلسة: بلا مستخدم ← الدخول، موظف/مدير ← لوحة الإدارة،
/// مستخدم عادي ← واجهة المستخدم.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser;
        if (user == null) return const LoginScreen();
        if (user.role.isStaff) return const StaffDashboard();
        return const UserShell();
      },
    );
  }
}
