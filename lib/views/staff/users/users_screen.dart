import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/user_form/user_form_screen.dart';
import 'package:librarry_app/views/staff/users/users_cubit.dart';
import 'package:librarry_app/views/staff/users/users_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

/// الحسابات (للمدير): إنشاء حساب، ترقية الصلاحيات، وتعطيل الحساب بدل حذفه.
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
                'ترقية الصلاحية وإنشاء الحسابات وتعطيلها من صلاحيات مدير النظام فقط. '
                'لا يمكنك تغيير حسابك أنت، ولا إزالة أو تعطيل آخر مدير للنظام. '
                'الحساب المعطّل لا يستطيع الدخول وتبقى بياناته وسجل استعاراته محفوظة، '
                'ويمكن إعادة تفعيله في أي وقت.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final u in state.users)
                _UserCard(user: u, isMe: u.username == state.meUsername),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.isMe});

  final AppUser user;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final u = user;
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      child: Opacity(
        opacity: u.disabled ? 0.65 : 1,
        child: ListTile(
          title: Row(
            children: [
              Flexible(child: Text(u.fullName)),
              if (u.disabled) ...[
                const SizedBox(width: 8),
                const StatusChip(label: 'معطّل', tone: Tone.danger),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isMe ? '${u.username} · أنت' : u.username),
              // جهة العمل والهاتف كما أدخلهما صاحب الحساب (يراها المدير فقط).
              for (final line in u.orgLines)
                Text(line, style: Theme.of(context).textTheme.bodySmall),
              if (u.phone.isNotEmpty)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('☎ ${u.phone}', style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
              if (u.orgLines.isEmpty && u.phone.isEmpty)
                Text(
                  'لم يُدخل بيانات الجهة',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              if (u.disabled)
                Text(
                  'السبب: ${u.disabledReason}'
                  '${u.disabledAt == null ? '' : ' · ${arabicDate(u.disabledAt!)}'}',
                  style: TextStyle(color: scheme.error, fontSize: 12),
                ),
            ],
          ),
          isThreeLine: u.disabled,
          trailing: isMe
              ? Text(u.role.shortLabel)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<UserRole>(
                      value: u.role,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final r in UserRole.values)
                          DropdownMenuItem(value: r, child: Text(r.shortLabel)),
                      ],
                      onChanged: (r) => _changeRole(context, r),
                    ),
                    IconButton(
                      tooltip: 'إعادة تعيين كلمة المرور',
                      icon: const Icon(Icons.lock_reset),
                      onPressed: () => _resetPassword(context),
                    ),
                    IconButton(
                      tooltip: u.disabled ? 'إعادة التفعيل' : 'تعطيل الحساب',
                      icon: Icon(
                        u.disabled ? Icons.lock_open_outlined : Icons.block_outlined,
                      ),
                      onPressed: () => _toggleDisabled(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _changeRole(BuildContext context, UserRole? r) async {
    if (r == null || r == user.role) return;
    final cubit = context.read<UsersCubit>();
    if (r == UserRole.admin) {
      final yes = await confirmDialog(
        context,
        title: 'تأكيد الترقية',
        message: 'هل تريد جعل ${user.fullName} «${r.label}»؟ '
            'سيحصل على كل صلاحيات الإدارة، ومنها ترقية '
            'المستخدمين وإنشاء الحسابات.',
        confirmLabel: 'ترقية',
      );
      if (!yes || !context.mounted) return;
    }
    await runAction(
      context,
      () => cubit.setRole(user.username, r),
      success: 'تم تغيير الدور',
      ms: 500,
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    final cubit = context.read<UsersCubit>();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(name: user.fullName),
    );
    if (password == null || !context.mounted) return;
    await runAction(
      context,
      () => cubit.resetPassword(user.username, password),
      success: 'تم تعيين كلمة مرور جديدة لحساب ${user.fullName}',
      ms: 600,
    );
  }

  Future<void> _toggleDisabled(BuildContext context) async {
    final cubit = context.read<UsersCubit>();
    if (user.disabled) {
      await runAction(
        context,
        () => cubit.enable(user.username),
        success: 'أُعيد تفعيل الحساب',
        ms: 600,
      );
      return;
    }
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _DisableDialog(name: user.fullName),
    );
    if (reason == null || !context.mounted) return;
    await runAction(
      context,
      () => cubit.disable(user.username, reason),
      success: 'تم تعطيل الحساب',
      ms: 600,
    );
  }
}

/// نافذة التعطيل: تطلب سبباً إلزامياً قبل المتابعة.
class _DisableDialog extends StatefulWidget {
  const _DisableDialog({required this.name});

  final String name;

  @override
  State<_DisableDialog> createState() => _DisableDialogState();
}

class _DisableDialogState extends State<_DisableDialog> {
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _reason.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'اكتب سبب التعطيل');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعطيل الحساب'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل تريد تعطيل حساب ${widget.name}؟ لن يستطيع الدخول، وتبقى بياناته '
            'وسجل استعاراته كما هي. يمكنك إعادة تفعيله لاحقاً.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: 'سبب التعطيل (إلزامي)',
              hintText: 'مثال: انتهاء التعاون، أو كتاب لم يُعد',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _submit,
          child: const Text('تعطيل'),
        ),
      ],
    );
  }
}

/// نافذة إعادة تعيين كلمة المرور: يكتب المدير كلمة جديدة (6 أحرف على الأقل).
class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.name});

  final String name;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _password.text;
    if (text.length < LibraryStore.minPasswordLength) {
      setState(() => _error = 'كلمة المرور يجب ألا تقل عن ${LibraryStore.minPasswordLength} أحرف');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعادة تعيين كلمة المرور'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعيين كلمة مرور جديدة لحساب ${widget.name}. تُسجَّل العملية في سجل '
            'النشاط ويصله إشعار ليغيّرها بعد الدخول.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            autofocus: true,
            autocorrect: false,
            textDirection: TextDirection.ltr,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'كلمة المرور الجديدة (6 أحرف على الأقل)',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _submit, child: const Text('تعيين')),
      ],
    );
  }
}
