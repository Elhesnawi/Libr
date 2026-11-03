import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/common/change_password/change_password_cubit.dart';
import 'package:librarry_app/views/common/change_password/change_password_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordCubit(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<ChangePasswordCubit>();
    if (!cubit.validate(_new.text, _confirm.text)) return;
    final nav = Navigator.of(context);
    final ok = await runAction(
      context,
      () => cubit.save(_old.text, _new.text),
      success: 'تم تغيير كلمة المرور',
      onError: cubit.showError,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LibraryAppBar(title: 'تغيير كلمة المرور'),
      body: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _old,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _new,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة (6 أحرف على الأقل)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 10),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('حفظ')),
          ],
        ),
      ),
    );
  }
}
