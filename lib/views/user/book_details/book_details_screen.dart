import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/book_details/book_details_cubit.dart';
import 'package:librarry_app/views/user/book_details/book_details_state.dart';
import 'package:librarry_app/views/user/rating/rating_screen.dart';
import 'package:librarry_app/views/user/reader/reader_screen.dart';
import 'package:librarry_app/widgets/book_cover.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// صفحة تفاصيل الكتاب (للموظف، ولأي مستخدم يضغط "التقييمات").
class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookDetailsCubit(bookId),
      child: BlocBuilder<BookDetailsCubit, BookDetailsState>(
        builder: (context, state) {
          if (state.book == null) {
            return const Scaffold(
              appBar: LibraryAppBar(title: 'تفاصيل الكتاب'),
              body: EmptyState(message: 'هذا الكتاب لم يعد موجوداً'),
            );
          }
          return Scaffold(
            appBar: const LibraryAppBar(title: 'تفاصيل الكتاب'),
            body: _Body(state: state),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final BookDetailsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookDetailsCubit>();
    final book = state.book!;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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
              BookCover(book: book, width: 78, height: 104, iconSize: 34),
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
                      'القسم: ${state.categoryName} · ${book.isDigital ? 'رقمي' : 'ورقي'}',
                      style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    Text(
                      'الرمز: ${book.code}',
                      style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    Text(
                      'تاريخ النشر: ${book.publishDate == null ? '—' : arabicDate(book.publishDate!)}',
                      style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (!book.isDigital)
          Row(
            children: [
              Text('النسخ المتاحة: ${book.availableCopies} من ${book.totalCopies}'),
              const Spacer(),
              StatusChip(
                label: book.isAvailable ? 'متاح' : 'غير متاح',
                tone: book.isAvailable ? Tone.success : Tone.danger,
              ),
            ],
          )
        else
          Row(
            children: [
              const Text('نسخة رقمية (PDF)'),
              const Spacer(),
              Text(
                book.fileName ?? '',
                textDirection: TextDirection.ltr,
                style: text.bodySmall,
              ),
            ],
          ),
        if (book.isDigital) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.chrome_reader_mode_outlined),
                  label: Text(state.readingPage > 0
                      ? 'تابع القراءة (صفحة ${state.readingPage})'
                      : 'قراءة'),
                  onPressed: () => openScreen(context, ReaderScreen(bookId: book.id)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('تحميل'),
                  onPressed: () => runAction(
                    context,
                    cubit.download,
                    success: 'تم التحميل (محاكاة). في التطبيق الحقيقي يُحفظ الملف على جهازك',
                    ms: 800,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (!state.isStaff && !book.isDigital) ...[
          const SizedBox(height: 12),
          if (book.isAvailable)
            FilledButton.icon(
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('استعارة (14 يوماً)'),
              onPressed: () => runAction(
                context,
                cubit.borrow,
                success: 'تمت الاستعارة. موعد الإرجاع بعد ${LibraryStore.loanDays} يوماً',
                ms: 800,
              ),
            )
          else
            FilledButton.icon(
              icon: const Icon(Icons.schedule),
              label: Text(state.reserved ? 'تم حجز الكتاب لك' : 'حجز الكتاب'),
              onPressed: state.reserved
                  ? null
                  : () => runAction(
                        context,
                        cubit.reserve,
                        success: 'تم الحجز. سنخطرك عند توفر الكتاب',
                      ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(state.isFavorite ? Icons.bookmark : Icons.bookmark_border),
            label: Text(state.isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة'),
            onPressed: () {
              final added = cubit.toggleFavorite();
              showMessage(
                context,
                added ? 'أُضيف إلى المفضلة' : 'أُزيل من المفضلة',
              );
            },
          ),
        ],
        if (!state.isStaff && book.isDigital) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(state.isFavorite ? Icons.bookmark : Icons.bookmark_border),
            label: Text(state.isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة'),
            onPressed: () {
              final added = cubit.toggleFavorite();
              showMessage(context, added ? 'أُضيف إلى المفضلة' : 'أُزيل من المفضلة');
            },
          ),
        ],
        const SizedBox(height: 20),
        RatingSection(bookId: book.id),
      ],
    );
  }
}
