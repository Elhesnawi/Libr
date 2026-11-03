import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/book_cover.dart';
import 'package:librarry_app/widgets/book_popup.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/rating_section.dart';

/// سطر كتاب: غلاف مبسّط + العنوان والمؤلف والقسم + حالة التوفر.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.trailing, this.onTap});

  final Book book;

  /// بديل لشارة التوفر (مثل شارة موعد الإرجاع).
  final Widget? trailing;

  /// افتراضياً: نافذة منبثقة للمستخدم، وصفحة التفاصيل للموظف.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = LibraryStore.instance.categoryById(book.categoryId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        onTap: onTap ?? () => openBook(context, book.id),
        leading: BookCover(book: book),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${book.author} · ${category?.name ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (LibraryStore.instance.ratingCount(book.id) > 0)
              Row(
                children: [
                  StarsView(value: LibraryStore.instance.averageRating(book.id), size: 13),
                  const SizedBox(width: 4),
                  Text(
                    LibraryStore.instance.averageRating(book.id).toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
        trailing: trailing ??
            StatusChip(
              label: book.isDigital ? 'رقمي' : (book.isAvailable ? 'متاح' : 'غير متاح'),
              tone: book.isDigital
                  ? Tone.warning
                  : (book.isAvailable ? Tone.success : Tone.danger),
            ),
      ),
    );
  }
}

/// قائمة كتب جاهزة (مع حالة "لا توجد نتائج").
class BookList extends StatelessWidget {
  const BookList({super.key, required this.books, this.emptyMessage = 'لا توجد نتائج'});

  final List<Book> books;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return EmptyState(message: emptyMessage);
    return Column(children: [for (final b in books) BookTile(book: b)]);
  }
}
