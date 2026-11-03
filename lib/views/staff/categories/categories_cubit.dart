import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/categories/categories_state.dart';

class CategoriesCubit extends StoreCubit<CategoriesState> {
  CategoriesCubit() : super(CategoriesState.from(LibraryStore.instance));

  @override
  void refresh() => emit(CategoriesState.from(store));

  void delete(int categoryId) => store.deleteCategory(categoryId);
}
