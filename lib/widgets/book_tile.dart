import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/book_details_screen.dart';
import 'package:librarry_app/widgets/common.dart';

/// سطر كتاب: غلاف مبسّط + العنوان والمؤلف والقسم + حالة التوفر.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.trailing, this.onTap});

  final Book book;

  /// بديل لشارة التوفر (مثل شارة موعد الإرجاع).
  final Widget? trailing;

  /// افتراضياً يفتح تفاصيل الكتاب.
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
        onTap: onTap ?? () => openScreen(context, BookDetailsScreen(bookId: book.id)),
        leading: Container(
          width: 40,
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            book.isDigital ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined,
            color: scheme.onPrimaryContainer,
          ),
        ),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${book.author} · ${category?.name ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ??
            StatusChip(
              label: book.isAvailable ? 'متاح' : 'غير متاح',
              tone: book.isAvailable ? Tone.success : Tone.danger,
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
