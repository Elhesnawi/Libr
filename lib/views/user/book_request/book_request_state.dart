import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class BookRequestState {
  const BookRequestState({required this.requests});

  final List<BookRequest> requests;

  factory BookRequestState.from(LibraryStore s) {
    final user = s.currentUser;
    return BookRequestState(
      requests: user == null ? const [] : s.requestsOf(user.username),
    );
  }
}
