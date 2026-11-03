import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class BookRow {
  const BookRow({required this.book, required this.categoryName});

  final Book book;
  final String categoryName;
}

class ManageBooksState {
  const ManageBooksState({required this.rows});

  final List<BookRow> rows;

  factory ManageBooksState.from(LibraryStore s) => ManageBooksState(
        rows: [
          for (final b in s.books)
            BookRow(book: b, categoryName: s.categoryById(b.categoryId)?.name ?? ''),
        ],
      );
}
