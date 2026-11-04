import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/user/reader/reader_cubit.dart';
import 'package:librarry_app/views/user/reader/reader_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// قارئ الكتب الرقمية (تجريبي). يتذكر آخر صفحة وصل إليها المستخدم.
/// عند ربط التخزين السحابي يعرض هذا القارئ ملف PDF الحقيقي.
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReaderCubit(bookId),
      child: BlocBuilder<ReaderCubit, ReaderState>(
        builder: (context, state) {
          final book = state.book;
          if (book == null) {
            return const Scaffold(
              appBar: LibraryAppBar(title: 'القارئ'),
              body: EmptyState(message: 'هذا الكتاب لم يعد موجوداً'),
            );
          }
          final cubit = context.read<ReaderCubit>();
          final page = state.page;
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
                      onPressed: page <= 1 ? null : cubit.previous,
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
                      onPressed: page >= book.pages ? null : cubit.next,
                      child: const Text('التالية'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}
