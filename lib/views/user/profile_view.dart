import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/common/change_password_screen.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// محتوى صفحة الحساب (يُستخدم للمستخدم وللموظف والمدير).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    // يستمع للمخزن بنفسه، لأن النسخة const لا تُعاد بناؤها من الأب.
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => _content(context, store),
    );
  }

  Widget _content(BuildContext context, LibraryStore store) {
    final user = store.currentUser;
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
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('الوضع الليلي'),
                value: store.darkMode,
                onChanged: store.setDarkMode,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('تغيير كلمة المرور'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => openScreen(context, const ChangePasswordScreen()),
              ),
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
  }
}

/// صفحة حساب مستقلة (للموظف والمدير من لوحة الإدارة).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LibraryStore.instance,
      builder: (context, _) => const Scaffold(
        appBar: LibraryAppBar(title: 'حسابي'),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ProfileView(),
        ),
      ),
    );
  }
}
