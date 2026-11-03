import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/scan/scan_state.dart';

/// مسح الباركود للاستعارة والإرجاع السريع (محاكاة بقوائم اختيار حالياً).
class ScanCubit extends StoreCubit<ScanState> {
  ScanCubit() : super(ScanState.initial(LibraryStore.instance));

  @override
  void refresh() {
    final fresh = ScanState.initial(store);
    final u = state.username;
    final b = state.bookId;
    emit(ScanState(
      members: fresh.members,
      books: fresh.books,
      borrow: state.borrow,
      username: fresh.members.any((m) => m.username == u) ? u : fresh.username,
      bookId: fresh.books.any((x) => x.id == b) ? b : fresh.bookId,
    ));
  }

  void setBorrow(bool value) => emit(state.copyWith(borrow: value));

  void setUsername(String? value) {
    if (value != null) emit(state.copyWith(username: value));
  }

  void setBook(int? value) {
    if (value != null) emit(state.copyWith(bookId: value));
  }

  bool get ready => state.username != null && state.bookId != null;

  /// ينفّذ الاستعارة أو الإرجاع. يرمي [LibraryException] عند المخالفة.
  void confirm() {
    final username = state.username;
    final bookId = state.bookId;
    if (username == null || bookId == null) {
      throw LibraryException('اختر المستعير والكتاب');
    }
    if (state.borrow) {
      store.borrow(bookId, forUsername: username);
    } else {
      store.returnByScan(username, bookId);
    }
  }
}
