import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class ReaderState {
  const ReaderState({required this.book, required this.page});

  final Book? book;

  /// الصفحة الحالية (1 على الأقل).
  final int page;

  factory ReaderState.from(LibraryStore s, int bookId) {
    final saved = s.readingPage(bookId);
    return ReaderState(book: s.bookById(bookId), page: saved == 0 ? 1 : saved);
  }
}
