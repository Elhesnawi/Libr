import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/home/home_state.dart';

class HomeCubit extends StoreCubit<HomeState> {
  HomeCubit()
      : super(HomeState.from(LibraryStore.instance, type: LibraryType.paper));

  void setQuery(String query) =>
      emit(HomeState.from(store, type: state.type, query: query));

  void setType(LibraryType type) =>
      emit(HomeState.from(store, type: type, query: state.query));

  @override
  void refresh() => emit(HomeState.from(store, type: state.type, query: state.query));
}
