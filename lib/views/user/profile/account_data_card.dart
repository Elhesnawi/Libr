import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/user/profile/profile_cubit.dart';
import 'package:librarry_app/widgets/common.dart';

/// بطاقة «بيانات الحساب»: جهة العمل (إدارة عامة / فرع / مكتب) ورقم الهاتف.
/// تعرض القيم الحالية، وزر «تعديل» يفتح نموذج الإدخال داخل البطاقة نفسها.
class AccountDataCard extends StatefulWidget {
  const AccountDataCard({super.key, required this.user});

  final AppUser user;

  @override
  State<AccountDataCard> createState() => _AccountDataCardState();
}

class _AccountDataCardState extends State<AccountDataCard> {
  bool _editing = false;
  OrgKind _kind = OrgKind.general;
  final Map<OrgKind, List<TextEditingController>> _fields = {
    for (final k in OrgKind.values)
      k: [for (final _ in k.fieldLabels) TextEditingController()],
  };
  final _phone = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final list in _fields.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    _phone.dispose();
    super.dispose();
  }

  void _startEdit() {
    final u = widget.user;
    for (final list in _fields.values) {
      for (final c in list) {
        c.clear();
      }
    }
    _kind = u.orgKind ?? OrgKind.general;
    final list = _fields[_kind]!;
    for (var i = 0; i < list.length && i < u.orgValues.length; i++) {
      list[i].text = u.orgValues[i];
    }
    _phone.text = u.phone;
    setState(() {
      _editing = true;
      _error = null;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final cubit = context.read<ProfileCubit>();
    final values = [for (final c in _fields[_kind]!) c.text];
    final ok = await runAction(
      context,
      () => cubit.saveAccountData(kind: _kind, values: values, phone: _phone.text),
      success: 'تم حفظ بيانات الحساب',
      ms: 500,
      onError: (m) => setState(() => _error = m),
    );
    if (ok && mounted) setState(() => _editing = false);
  }

  Future<void> _clear() async {
    final cubit = context.read<ProfileCubit>();
    final ok = await runAction(
      context,
      () => cubit.saveAccountData(kind: null, values: const [], phone: _phone.text),
      success: 'تم مسح جهة العمل',
      ms: 400,
      onError: (m) => setState(() => _error = m),
    );
    if (ok && mounted) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: _editing ? _form(scheme, text) : _view(scheme, text),
      ),
    );
  }

  Widget _view(ColorScheme scheme, TextTheme text) {
    final u = widget.user;
    final kind = u.orgKind;
    final labels = kind?.fieldLabels ?? const <String>[];
    final rows = <Widget>[
      if (kind != null)
        for (var i = 0; i < labels.length && i < u.orgValues.length; i++)
          if (u.orgValues[i].trim().isNotEmpty) _row(labels[i], u.orgValues[i], text, scheme),
      if (u.phone.isNotEmpty) _row('رقم الهاتف', u.phone, text, scheme),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.badge_outlined, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text('بيانات الحساب',
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            TextButton.icon(
              onPressed: _startEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(rows.isEmpty ? 'إضافة' : 'تعديل'),
            ),
          ],
        ),
        if (rows.isEmpty)
          Text(
            'أضف جهة عملك (إدارة عامة أو فرع أو مكتب) ورقم هاتفك.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          )
        else
          ...rows,
      ],
    );
  }

  Widget _row(String label, String value, TextTheme text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _form(ColorScheme scheme, TextTheme text) {
    final labels = _kind.fieldLabels;
    final controllers = _fields[_kind]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('بيانات الحساب', style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SegmentedButton<OrgKind>(
          showSelectedIcon: false,
          segments: [
            for (final k in OrgKind.values) ButtonSegment(value: k, label: Text(k.label)),
          ],
          selected: {_kind},
          onSelectionChanged: (s) => setState(() {
            _kind = s.first;
            _error = null;
          }),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < labels.length; i++) ...[
          TextField(
            controller: controllers[i],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: i == 0 ? labels[i] : '${labels[i]} (اختياري)',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف (اختياري)',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: scheme.error)),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(onPressed: _save, child: const Text('حفظ')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _editing = false),
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ),
        if (widget.user.orgKind != null)
          TextButton(onPressed: _clear, child: const Text('مسح جهة العمل')),
      ],
    );
  }
}
