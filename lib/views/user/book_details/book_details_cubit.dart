import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/book_details/book_details_state.dart';

class BookDetailsCubit extends StoreCubit<BookDetailsState> {
  BookDetailsCubit(this.bookId)
      : super(BookDetailsState.from(LibraryStore.instance, bookId));

  final int bookId;

  @override
  void refresh() => emit(BookDetailsState.from(store, bookId));

  void borrow() => store.borrow(bookId);

  void reserve() => store.reserve(bookId);

  void download() => store.downloadBook(bookId);

  /// يعيد true إذا أُضيف إلى المفضلة، وfalse إذا أُزيل.
  bool toggleFavorite() => store.toggleFavorite(bookId);
}
