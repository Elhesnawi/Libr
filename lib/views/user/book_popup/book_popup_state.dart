import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class BookPopupState {
  const BookPopupState({
    required this.book,
    required this.categoryName,
    required this.myLoan,
    required this.reserved,
    required this.ratingCount,
    required this.average,
    required this.started,
  });

  final Book? book;
  final String categoryName;

  /// استعارة المستخدم الحالية لهذا الكتاب إن وجدت.
  final Loan? myLoan;
  final bool reserved;
  final int ratingCount;
  final double average;

  /// هل بدأ المستخدم قراءة الكتاب الرقمي؟
  final bool started;

  factory BookPopupState.from(LibraryStore s, int bookId) {
    final book = s.bookById(bookId);
    final mine = s
        .activeLoansOf(s.currentUser?.username ?? '')
        .where((l) => l.bookId == bookId)
        .toList();
    return BookPopupState(
      book: book,
      categoryName: book == null ? '' : (s.categoryById(book.categoryId)?.name ?? ''),
      myLoan: mine.isEmpty ? null : mine.first,
      reserved: s.hasReserved(bookId),
      ratingCount: s.ratingCount(bookId),
      average: s.averageRating(bookId),
      started: s.readingPage(bookId) > 0,
    );
  }
}
