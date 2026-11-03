import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// قارئ الكتب الرقمية (تجريبي). يتذكر آخر صفحة وصل إليها المستخدم.
/// عند ربط التخزين السحابي يعرض هذا القارئ ملف PDF الحقيقي.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  final int bookId;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  @override
  void initState() {
    super.initState();
    // نسجل بدء القراءة بعد بناء الشاشة لتجنب إشعار المستمعين أثناء البناء.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = LibraryStore.instance;
      if (store.readingPage(widget.bookId) == 0) {
        _go(1);
      }
    });
  }

  void _go(int page) {
    try {
      LibraryStore.instance.setReadingPage(widget.bookId, page);
    } on LibraryException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final book = store.bookById(widget.bookId);
        if (book == null) {
          return const Scaffold(
            appBar: LibraryAppBar(title: 'القارئ'),
            body: EmptyState(message: 'هذا الكتاب لم يعد موجوداً'),
          );
        }
        final page = store.readingPage(book.id) == 0 ? 1 : store.readingPage(book.id);
        final scheme = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;
        return Scaffold(
          appBar: LibraryAppBar(title: book.title),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الفصل ${(page / 3).ceil()} · صفحة $page',
                            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'هذه صفحة تجريبية من كتاب «${book.title}» للمؤلف ${book.author}. '
                            'في التطبيق الحقيقي يعرض القارئ هنا الملف الذي رفعه أمين المكتبة'
                            '${book.fileName == null ? '' : ' (${book.fileName})'}.',
                            style: text.bodyLarge?.copyWith(height: 2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'تتذكر المكتبة آخر صفحة وصلت إليها، وتفتح الكتاب منها في المرة القادمة.',
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(minHeight: 6, value: page / book.pages),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: page <= 1 ? null : () => _go(page - 1),
                      child: const Text('السابقة'),
                    ),
                    Expanded(
                      child: Text(
                        'صفحة $page من ${book.pages}',
                        textAlign: TextAlign.center,
                        style: text.bodySmall,
                      ),
                    ),
                    FilledButton(
                      onPressed: page >= book.pages ? null : () => _go(page + 1),
                      child: const Text('التالية'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
