import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/book_request/book_request_state.dart';

class BookRequestCubit extends StoreCubit<BookRequestState> {
  BookRequestCubit() : super(BookRequestState.from(LibraryStore.instance));

  @override
  void refresh() => emit(BookRequestState.from(store));

  void submit(String title, String author) =>
      store.submitRequest(title: title, author: author);
}
