import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';

/// غلاف الكتاب: الصورة التي رفعها أمين المكتبة، أو أيقونة عند عدم وجودها.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width = 40,
    this.height = 52,
    this.iconSize = 24,
  });

  final Book book;
  final double width;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bytes = book.coverBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        color: scheme.primaryContainer,
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true)
            : Icon(
                book.isDigital ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined,
                size: iconSize,
                color: scheme.onPrimaryContainer,
              ),
      ),
    );
  }
}
