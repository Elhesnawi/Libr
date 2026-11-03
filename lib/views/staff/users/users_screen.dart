import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/staff/user_form/user_form_screen.dart';
import 'package:librarry_app/views/staff/users/users_cubit.dart';
import 'package:librarry_app/views/staff/users/users_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

/// الحسابات (للمدير): إنشاء حساب وترقية الصلاحيات.
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'الحسابات'),
        body: BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: const Text('إنشاء حساب'),
                onPressed: () => openScreen(context, const UserFormScreen()),
              ),
              const SizedBox(height: 8),
              Text(
                'ترقية الصلاحية وإنشاء الحسابات من صلاحيات مدير النظام فقط. '
                'لا يمكنك تغيير صلاحية حسابك، ولا إزالة آخر مدير للنظام.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final u in state.users)
                SoftCard(
                  child: ListTile(
                    title: Text(u.fullName),
                    subtitle: Text(u.username),
                    trailing: u.username == state.meUsername
                        ? Text(u.role.shortLabel)
                        : DropdownButton<UserRole>(
                            value: u.role,
                            underline: const SizedBox.shrink(),
                            items: [
                              for (final r in UserRole.values)
                                DropdownMenuItem(value: r, child: Text(r.shortLabel)),
                            ],
                            onChanged: (r) => _changeRole(context, u, r),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeRole(BuildContext context, AppUser u, UserRole? r) async {
    if (r == null || r == u.role) return;
    final cubit = context.read<UsersCubit>();
    if (r == UserRole.admin) {
      final yes = await confirmDialog(
        context,
        title: 'تأكيد الترقية',
        message: 'هل تريد جعل ${u.fullName} «${r.label}»؟ '
            'سيحصل على كل صلاحيات الإدارة، ومنها ترقية '
            'المستخدمين وإنشاء الحسابات.',
        confirmLabel: 'ترقية',
      );
      if (!yes || !context.mounted) return;
    }
    await runAction(
      context,
      () => cubit.setRole(u.username, r),
      success: 'تم تغيير الدور',
      ms: 500,
    );
  }
}
