import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final book = store.bookById(bookId);
        final user = store.currentUser;
        if (book == null || user == null) {
          return const Scaffold(
            appBar: LibraryAppBar(title: 'تفاصيل الكتاب'),
            body: EmptyState(message: 'هذا الكتاب لم يعد موجوداً'),
          );
        }
        return Scaffold(
          appBar: const LibraryAppBar(title: 'تفاصيل الكتاب'),
          body: _Body(book: book, isStaff: user.role.isStaff),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.book, required this.isStaff});

  final Book book;
  final bool isStaff;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = store.categoryById(book.categoryId);
    final isFav = store.isFavorite(book.id);
    final reserved = store.hasReserved(book.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  book.isDigital ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined,
                  size: 34,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(book.author, style: TextStyle(color: scheme.onPrimaryContainer)),
                    Text(
                      'القسم: ${category?.name ?? ''} · ${book.isDigital ? 'رقمي' : 'ورقي'}',
                      style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    Text(
                      'الرمز: ${book.code}',
                      style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('النسخ المتاحة: ${book.availableCopies} من ${book.totalCopies}'),
            const Spacer(),
            StatusChip(
              label: book.isAvailable ? 'متاح' : 'غير متاح',
              tone: book.isAvailable ? Tone.success : Tone.danger,
            ),
          ],
        ),
        if (book.isDigital) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.chrome_reader_mode_outlined),
                  label: const Text('قراءة'),
                  onPressed: () => showMessage(
                    context,
                    'القراءة والتحميل تعملان بعد ربط ملفات الكتب بالخادم',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('تحميل'),
                  onPressed: () => showMessage(
                    context,
                    'القراءة والتحميل تعملان بعد ربط ملفات الكتب بالخادم',
                  ),
                ),
              ),
            ],
          ),
        ],
        if (!isStaff) ...[
          const SizedBox(height: 12),
          if (book.isAvailable)
            FilledButton.icon(
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('استعارة (14 يوماً)'),
              onPressed: () => runAction(
                context,
                () => store.borrow(book.id),
                success: 'تمت الاستعارة. موعد الإرجاع بعد ${LibraryStore.loanDays} يوماً',
                ms: 800,
              ),
            )
          else
            FilledButton.icon(
              icon: const Icon(Icons.schedule),
              label: Text(reserved ? 'تم حجز الكتاب لك' : 'حجز الكتاب'),
              onPressed: reserved
                  ? null
                  : () => runAction(
                        context,
                        () => store.reserve(book.id),
                        success: 'تم الحجز. سنخطرك عند توفر الكتاب',
                      ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border),
            label: Text(isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة'),
            onPressed: () {
              final added = store.toggleFavorite(book.id);
              showMessage(
                context,
                added ? 'أُضيف إلى المفضلة' : 'أُزيل من المفضلة',
              );
            },
          ),
        ],
      ],
    );
  }
}
