import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/category_books/category_books_state.dart';

class CategoryBooksCubit extends StoreCubit<CategoryBooksState> {
  CategoryBooksCubit(this.categoryId, this.type)
      : super(CategoryBooksState.from(LibraryStore.instance, categoryId, type));

  final int categoryId;
  final LibraryType type;

  @override
  void refresh() => emit(CategoryBooksState.from(store, categoryId, type));
}
