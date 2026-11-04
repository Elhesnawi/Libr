import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/reader/reader_state.dart';

class ReaderCubit extends StoreCubit<ReaderState> {
  ReaderCubit(this.bookId) : super(ReaderState.from(LibraryStore.instance, bookId)) {
    // نسجل بدء القراءة بعد الإنشاء مباشرة لتجنب إشعار المستمعين أثناء بناء الشاشة.
    Future.microtask(() {
      if (!isClosed && store.readingPage(bookId) == 0) goTo(1);
    });
  }

  final int bookId;

  @override
  void refresh() => emit(ReaderState.from(store, bookId));

  /// يرمي [LibraryException] إذا كانت الصفحة خارج الكتاب.
  void goTo(int page) => store.setReadingPage(bookId, page);

  void next() => goTo(state.page + 1);

  void previous() => goTo(state.page - 1);
}
