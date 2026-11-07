import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/auth/auth_state.dart';
import 'package:librarry_app/widgets/common.dart';

/// صورة المستخدم في الشريط العلوي: تفتح قائمة فيها بيانات الحساب،
/// الوضع الليلي/النهاري، إشعارات الهاتف (قريباً)، وتسجيل الخروج.
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key, required this.onOpenAccount});

  /// ما يحدث عند اختيار «بيانات حسابي» (تبويب للمستخدم، شاشة للموظف).
  final VoidCallback onOpenAccount;

  static const _account = 'account';
  static const _theme = 'theme';
  static const _notify = 'notify';
  static const _logout = 'logout';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();
        final name = user.fullName.trim();
        final initial = name.isEmpty ? '؟' : name.characters.first;
        return PopupMenuButton<String>(
          tooltip: 'قائمة الحساب',
          offset: const Offset(0, 48),
          onSelected: (value) {
            switch (value) {
              case _account:
                onOpenAccount();
                break;
              case _theme:
                context.read<AuthCubit>().toggleDarkMode();
                break;
              case _logout:
                logoutUser(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _account,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_outline),
                title: Text('بيانات حسابي'),
              ),
            ),
            PopupMenuItem(
              value: _theme,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(auth.darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                title: Text(auth.darkMode ? 'الوضع النهاري' : 'الوضع الليلي'),
              ),
            ),
            const PopupMenuItem(
              value: _notify,
              enabled: false,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.notifications_active_outlined),
                title: Text('إشعارات الهاتف'),
                trailing: Text('قريباً', style: TextStyle(fontSize: 12)),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _logout,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: scheme.error),
                title: Text('تسجيل الخروج', style: TextStyle(color: scheme.error)),
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: scheme.primary,
              child: Text(
                initial,
                style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
