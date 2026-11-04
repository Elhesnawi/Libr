import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class BookDetailsState {
  const BookDetailsState({
    required this.book,
    required this.categoryName,
    required this.isStaff,
    required this.isFavorite,
    required this.reserved,
    required this.readingPage,
  });

  /// null عند حذف الكتاب أو انتهاء الجلسة.
  final Book? book;
  final String categoryName;
  final bool isStaff;
  final bool isFavorite;
  final bool reserved;
  final int readingPage;

  factory BookDetailsState.from(LibraryStore s, int bookId) {
    final book = s.bookById(bookId);
    final user = s.currentUser;
    return BookDetailsState(
      book: user == null ? null : book,
      categoryName: book == null ? '' : (s.categoryById(book.categoryId)?.name ?? ''),
      isStaff: user?.role.isStaff ?? false,
      isFavorite: s.isFavorite(bookId),
      reserved: s.hasReserved(bookId),
      readingPage: s.readingPage(bookId),
    );
  }
}
