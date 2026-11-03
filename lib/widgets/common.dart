import 'dart:async';

import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/widgets/loading_splash.dart';

/// يفتح شاشة جديدة بعد تحميل قصير بشعار الهيئة.
Future<void> openScreen(BuildContext context, Widget screen) async {
  final nav = Navigator.of(context);
  await withSplash<void>(context, () {}, ms: 350);
  if (!nav.mounted) return;
  await nav.push(MaterialPageRoute<void>(builder: (_) => screen));
}

/// تسجيل الخروج: يعود للشاشة الأولى ثم يمسح الجلسة (مع شاشة التحميل).
Future<void> logoutUser(BuildContext context) async {
  final nav = Navigator.of(context);
  nav.popUntil((route) => route.isFirst);
  await withSplash<void>(nav.context, LibraryStore.instance.logout, ms: 600);
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// ينفّذ عملية على المخزن مع شاشة التحميل، ويعرض رسالة نجاح أو الخطأ.
/// يعيد true عند النجاح.
Future<bool> runAction(
  BuildContext context,
  FutureOr<void> Function() action, {
  String? success,
  int ms = 700,
  void Function(String message)? onError,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  void say(String text) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  try {
    await withSplash<void>(context, action, ms: ms);
    if (success != null) say(success);
    return true;
  } on LibraryException catch (e) {
    if (onError != null) {
      onError(e.message);
    } else {
      say(e.message);
    }
    return false;
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

enum Tone { success, warning, danger, info }

/// شارة ملوّنة صغيرة (متاح، متأخر، مقبول...).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final Tone tone;

  static StatusChip forLoan(Loan loan) {
    final d = loan.daysLeft;
    return StatusChip(
      label: dueText(d),
      tone: d < 0
          ? Tone.danger
          : d <= 3
              ? Tone.warning
              : Tone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color base;
    switch (tone) {
      case Tone.success:
        base = Colors.green;
        break;
      case Tone.warning:
        base = Colors.orange;
        break;
      case Tone.danger:
        base = Colors.red;
        break;
      case Tone.info:
        base = Colors.blue;
        break;
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Color.lerp(base, Colors.white, 0.45)! : Color.lerp(base, Colors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: base.withValues(alpha: dark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
