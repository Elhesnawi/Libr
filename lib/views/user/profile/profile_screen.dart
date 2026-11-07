import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/common/change_password/change_password_screen.dart';
import 'package:librarry_app/views/user/profile/profile_cubit.dart';
import 'package:librarry_app/views/user/profile/profile_state.dart';
import 'package:librarry_app/views/user/shell/shell_navigation.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// محتوى صفحة الحساب (يُستخدم للمستخدم وللموظف والمدير).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const SizedBox.shrink();
          final scheme = Theme.of(context).colorScheme;
          final text = Theme.of(context).textTheme;
    return Column(
      children: [
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 38,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.person, size: 42, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(height: 10),
        Text(user.fullName, style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(
          '${user.username} · ${user.role.label}',
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Column(
            children: [
              // الكتب المستعارة والمفضلة للمستخدم العادي فقط (انتقلت من بطاقة الترحيب).
              if (!user.role.isStaff) ...[
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('الكتب المستعارة'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.loansCount} من ${LibraryStore.maxLoans}',
                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_left),
                    ],
                  ),
                  onTap: () => switchTab(context, 2),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('الكتب المفضلة'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.favoritesCount}',
                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_left),
                    ],
                  ),
                  onTap: () => switchTab(context, 3),
                ),
                const Divider(height: 1),
              ],
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('الوضع الليلي'),
                value: state.darkMode,
                onChanged: context.read<ProfileCubit>().setDarkMode,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('تغيير كلمة المرور'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => openScreen(context, const ChangePasswordScreen()),
              ),
              if (kDebugMode) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fast_forward_outlined),
                  title: const Text('محاكاة مرور يوم (للتجربة)'),
                  subtitle: const Text('يظهر في وضع التطوير فقط'),
                  onTap: () => runAction(
                    context,
                    context.read<ProfileCubit>().simulateDayPassed,
                    success: 'مضى يوم. راجع الإشعارات لرؤية التذكيرات الجديدة',
                    ms: 500,
                  ),
                ),
              ],
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: scheme.error),
                title: Text('تسجيل الخروج', style: TextStyle(color: scheme.error)),
                onTap: () => logoutUser(context),
              ),
            ],
          ),
        ),
      ],
    );

        },
      ),
    );
  }
}

/// صفحة حساب مستقلة (للموظف والمدير من لوحة الإدارة).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LibraryAppBar(title: 'حسابي'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ProfileView(),
      ),
    );
  }
}
