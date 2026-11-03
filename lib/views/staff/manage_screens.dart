import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/staff_forms.dart';
import 'package:librarry_app/widgets/book_cover.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// غلاف مشترك: شريط عنوان + استماع للمخزن + مسافات.
class _ManageScaffold extends StatelessWidget {
  const _ManageScaffold({required this.title, required this.builder});

  final String title;
  final List<Widget> Function(BuildContext context, LibraryStore store) builder;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: LibraryAppBar(title: title),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: builder(context, store),
        ),
      ),
    );
  }
}

Widget _card(BuildContext context, Widget child) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
    child: child,
  );
}

// ───────────────────────── إدارة الكتب ─────────────────────────

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'إدارة الكتب',
      builder: (context, store) => [
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('إضافة كتاب'),
          onPressed: () => openScreen(context, const BookFormScreen()),
        ),
        const SizedBox(height: 12),
        if (store.books.isEmpty) const EmptyState(message: 'لا توجد كتب'),
        for (final b in store.books)
          _card(
            context,
            ListTile(
              leading: BookCover(book: b),
              title: Text(b.title),
              subtitle: Text(
                '${b.code} · ${store.categoryById(b.categoryId)?.name ?? ''} · '
                '${b.isDigital ? 'رقمي' : '${b.availableCopies}/${b.totalCopies}'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'تعديل',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => openScreen(context, BookFormScreen(book: b)),
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    onPressed: () async {
                      final yes = await confirmDialog(
                        context,
                        title: 'حذف الكتاب',
                        message: 'هل تريد حذف "${b.title}"؟',
                        confirmLabel: 'حذف',
                      );
                      if (!yes || !context.mounted) return;
                      await runAction(
                        context,
                        () => store.deleteBook(b.id),
                        success: 'تم حذف الكتاب',
                        ms: 600,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── الأقسام ─────────────────────────

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'الأقسام',
      builder: (context, store) {
        final isAdmin = store.currentUser?.role == UserRole.admin;
        return [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إضافة قسم'),
            onPressed: () => openScreen(context, const CategoryFormScreen()),
          ),
          const SizedBox(height: 12),
          for (final c in store.categories)
            _card(
              context,
              ListTile(
                leading: Icon(c.icon),
                title: Text(c.name),
                subtitle: Text('${store.search(categoryId: c.id).length} كتب'),
                trailing: isAdmin
                    ? IconButton(
                        tooltip: 'حذف',
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () async {
                          final yes = await confirmDialog(
                            context,
                            title: 'حذف القسم',
                            message: 'هل تريد حذف قسم "${c.name}"؟',
                            confirmLabel: 'حذف',
                          );
                          if (!yes || !context.mounted) return;
                          await runAction(
                            context,
                            () => store.deleteCategory(c.id),
                            success: 'تم حذف القسم',
                            ms: 600,
                          );
                        },
                      )
                    : null,
              ),
            ),
          if (!isAdmin)
            Text(
              'حذف الأقسام للمدير فقط',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ];
      },
    );
  }
}

// ───────────────────────── الاستعارات ─────────────────────────

class LoansManageScreen extends StatelessWidget {
  const LoansManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'إدارة الاستعارات',
      builder: (context, store) {
        final loans = store.allActiveLoans;
        if (loans.isEmpty) {
          return [const EmptyState(message: 'لا توجد استعارات حالية')];
        }
        return [
          for (final loan in loans)
            _card(
              context,
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.bookById(loan.bookId)?.title ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        StatusChip.forLoan(loan),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المستعير: ${store.userByName(loan.username)?.fullName ?? loan.username}'
                      ' · الإرجاع: ${arabicDate(loan.dueAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: () => runAction(
                            context,
                            () => store.returnLoan(loan.id),
                            success: 'تم تسجيل الإرجاع',
                          ),
                          child: const Text('تسجيل إرجاع'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => runAction(
                            context,
                            () => store.extendLoan(loan.id),
                            success: 'تم التمديد ${LibraryStore.extendDays} أيام',
                            ms: 600,
                          ),
                          child: Text('تمديد ${LibraryStore.extendDays} أيام'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ];
      },
    );
  }
}

// ───────────────────────── التذكيرات ─────────────────────────

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'التذكيرات',
      builder: (context, store) {
        final loans = store.remindableLoans;
        return [
          Text(
            'المتأخرون ومن يحين موعد إرجاعهم اليوم أو غداً. يصلهم تنبيه تلقائي '
            'عند الدخول، ويمكنك إرسال تذكير يدوي.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          if (loans.isEmpty)
            const EmptyState(
              message: 'لا يوجد متأخرون ولا مستحقون قريباً',
              icon: Icons.check_circle_outline,
            )
          else ...[
            FilledButton.icon(
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text('إرسال تذكير للجميع (${loans.length})'),
              onPressed: () => runAction(
                context,
                store.remindAllDue,
                success: 'أُرسلت التذكيرات',
                ms: 600,
              ),
            ),
            const SizedBox(height: 10),
            for (final loan in loans)
              _card(
                context,
                ListTile(
                  title: Text(store.bookById(loan.bookId)?.title ?? ''),
                  subtitle: Text(
                    '${store.userByName(loan.username)?.fullName ?? loan.username}'
                    ' · ${arabicDate(loan.dueAt)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusChip.forLoan(loan),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => runAction(
                          context,
                          () => store.remindLoan(loan.id),
                          success: 'أُرسل التذكير',
                          ms: 400,
                        ),
                        child: const Text('تذكير'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ];
      },
    );
  }
}

// ───────────────────────── طلبات الكتب ─────────────────────────

class RequestsManageScreen extends StatelessWidget {
  const RequestsManageScreen({super.key});

  static Tone _tone(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return Tone.warning;
      case RequestStatus.accepted:
        return Tone.success;
      case RequestStatus.rejected:
        return Tone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'طلبات الكتب',
      builder: (context, store) {
        final list = store.allRequests;
        if (list.isEmpty) {
          return [const EmptyState(message: 'لا توجد طلبات', icon: Icons.lightbulb_outline)];
        }
        return [
          for (final r in list)
            _card(
              context,
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        StatusChip(label: r.status.label, tone: _tone(r.status)),
                      ],
                    ),
                    Text(
                      'المؤلف: ${r.author} · من: ${store.userByName(r.username)?.fullName ?? r.username}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (r.status == RequestStatus.pending) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.tonal(
                            onPressed: () => runAction(
                              context,
                              () => store.decideRequest(r.id, accepted: true),
                              success: 'تم قبول الطلب وإشعار المستخدم',
                              ms: 600,
                            ),
                            child: const Text('قبول'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => runAction(
                              context,
                              () => store.decideRequest(r.id, accepted: false),
                              success: 'تم رفض الطلب وإشعار المستخدم',
                              ms: 600,
                            ),
                            child: const Text('رفض'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ];
      },
    );
  }
}

// ───────────────────────── الإعلانات ─────────────────────────

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final ok = await runAction(
      context,
      () => LibraryStore.instance.addAnnouncement(_text.text),
      success: 'تم نشر الإعلان في الصفحة الرئيسية',
      ms: 600,
    );
    if (ok && mounted) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'الإعلانات',
      builder: (context, store) => [
        TextField(
          controller: _text,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'نص الإعلان',
            hintText: 'مثال: وصلت كتب جديدة في قسم القانون',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(onPressed: _publish, child: const Text('نشر في الرئيسية')),
        const SectionTitle('الإعلانات الحالية'),
        if (store.announcements.isEmpty) const EmptyState(message: 'لا توجد إعلانات'),
        for (final a in store.announcements)
          _card(
            context,
            ListTile(
              title: Text(a.text),
              subtitle: Text(arabicDate(a.date)),
              trailing: IconButton(
                tooltip: 'حذف',
                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                onPressed: () => runAction(
                  context,
                  () => store.deleteAnnouncement(a.id),
                  success: 'تم حذف الإعلان',
                  ms: 400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── سجل النشاط ─────────────────────────

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'سجل النشاط',
      builder: (context, store) => [
        if (store.logs.isEmpty) const EmptyState(message: 'لا توجد عمليات'),
        for (final l in store.logs)
          _card(
            context,
            ListTile(
              dense: true,
              title: Text(l.message),
              subtitle: Text('${l.username} · ${arabicDayAndTime(l.at)}'),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── الحسابات (للمدير) ─────────────────────────

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ManageScaffold(
      title: 'الحسابات',
      builder: (context, store) {
        final me = store.currentUser;
        return [
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
          for (final u in store.users)
            _card(
              context,
              ListTile(
                title: Text(u.fullName),
                subtitle: Text(u.username),
                trailing: u.username == me?.username
                    ? Text(u.role.shortLabel)
                    : DropdownButton<UserRole>(
                        value: u.role,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final r in UserRole.values)
                            DropdownMenuItem(value: r, child: Text(r.shortLabel)),
                        ],
                        onChanged: (r) async {
                          if (r == null || r == u.role) return;
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
                          runAction(
                            context,
                            () => store.setRole(u.username, r),
                            success: 'تم تغيير الدور',
                            ms: 500,
                          );
                        },
                      ),
              ),
            ),
        ];
      },
    );
  }
}
