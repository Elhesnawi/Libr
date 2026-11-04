import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/book_popup/book_popup_state.dart';

class BookPopupCubit extends StoreCubit<BookPopupState> {
  BookPopupCubit(this.bookId) : super(BookPopupState.from(LibraryStore.instance, bookId));

  final int bookId;

  @override
  void refresh() => emit(BookPopupState.from(store, bookId));

  /// هل المستخدم موظف أو مدير؟ (يفتح صفحة التفاصيل بدل النافذة)
  bool get isStaff => store.currentUser?.role.isStaff ?? false;

  bool get hasUser => store.currentUser != null;

  void borrow() => store.borrow(bookId);

  void reserve() => store.reserve(bookId);

  void download() => store.downloadBook(bookId);
}
