import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/manage_books/manage_books_state.dart';

class ManageBooksCubit extends StoreCubit<ManageBooksState> {
  ManageBooksCubit() : super(ManageBooksState.from(LibraryStore.instance));

  @override
  void refresh() => emit(ManageBooksState.from(store));

  void delete(int bookId) => store.deleteBook(bookId);
}
