import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/auth/auth_state.dart';
import 'package:librarry_app/views/login/login_screen.dart';
import 'package:librarry_app/views/staff/dashboard/dashboard_screen.dart';
import 'package:librarry_app/views/user/shell/shell_screen.dart';

/// يقرر الشاشة حسب الجلسة: بلا مستخدم ← الدخول، موظف/مدير ← لوحة الإدارة،
/// مستخدم عادي ← واجهة المستخدم.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.user?.username != current.user?.username ||
          previous.user?.role != current.user?.role,
      builder: (context, auth) {
        final user = auth.user;
        if (user == null) return const LoginScreen();
        if (user.role.isStaff) return const DashboardScreen();
        return const ShellScreen();
      },
    );
  }
}
