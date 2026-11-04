import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class ScanState {
  const ScanState({
    required this.members,
    required this.books,
    required this.borrow,
    required this.username,
    required this.bookId,
  });

  final List<AppUser> members;
  final List<Book> books;

  /// true: استعارة، false: إرجاع.
  final bool borrow;
  final String? username;
  final int? bookId;

  factory ScanState.initial(LibraryStore s) {
    final members =
        s.users.where((u) => u.role == UserRole.user && !u.disabled).toList();
    return ScanState(
      members: members,
      books: s.books,
      borrow: true,
      username: members.isEmpty ? null : members.first.username,
      bookId: s.books.isEmpty ? null : s.books.first.id,
    );
  }

  ScanState copyWith({bool? borrow, String? username, int? bookId}) => ScanState(
        members: members,
        books: books,
        borrow: borrow ?? this.borrow,
        username: username ?? this.username,
        bookId: bookId ?? this.bookId,
      );
}
