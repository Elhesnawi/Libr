import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/user_form/user_form_cubit.dart';
import 'package:librarry_app/views/staff/user_form/user_form_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

class UserFormScreen extends StatelessWidget {
  const UserFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserFormCubit(),
      child: const _UserFormView(),
    );
  }
}

class _UserFormView extends StatefulWidget {
  const _UserFormView();

  @override
  State<_UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<_UserFormView> {
  final _name = TextEditingController();
  final _username = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<UserFormCubit>();
    final nav = Navigator.of(context);
    final ok = await runAction(
      context,
      () => cubit.save(username: _username.text, fullName: _name.text),
      success: 'تم إنشاء الحساب. كلمة المرور المؤقتة: ${LibraryStore.tempPassword}',
      ms: 700,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserFormCubit>();
    return Scaffold(
      appBar: const LibraryAppBar(title: 'إنشاء حساب'),
      body: BlocBuilder<UserFormCubit, UserFormState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _username,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم (إنجليزي)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              initialValue: state.role,
              decoration: const InputDecoration(
                labelText: 'الصلاحية',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final r in UserRole.values)
                  DropdownMenuItem(value: r, child: Text(r.label)),
              ],
              onChanged: cubit.setRole,
            ),
            const SizedBox(height: 8),
            Text(
              'تُعطى كلمة مرور مؤقتة (${LibraryStore.tempPassword}) ويغيّرها المستخدم بعد أول دخول.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('إنشاء')),
          ],
        ),
      ),
    );
  }
}
