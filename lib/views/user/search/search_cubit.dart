import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/search/search_state.dart';

/// البحث الذكي: يتجاهل التشكيل والفروق بين الهمزات، مع تصفية بالقسم والنوع.
class SearchCubit extends StoreCubit<SearchState> {
  SearchCubit() : super(SearchState.from(LibraryStore.instance));

  void setQuery(String query) => emit(SearchState.from(
        store,
        query: query,
        categoryId: state.categoryId,
        type: state.type,
      ));

  void setCategory(int? categoryId) => emit(SearchState.from(
        store,
        query: state.query,
        categoryId: categoryId,
        type: state.type,
      ));

  void setType(LibraryType? type) => emit(SearchState.from(
        store,
        query: state.query,
        categoryId: state.categoryId,
        type: type,
      ));

  @override
  void refresh() => emit(SearchState.from(
        store,
        query: state.query,
        categoryId: state.categoryId,
        type: state.type,
      ));
}
