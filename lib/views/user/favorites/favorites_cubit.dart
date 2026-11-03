import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/favorites/favorites_state.dart';

class FavoritesCubit extends StoreCubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesState.from(LibraryStore.instance));

  @override
  void refresh() => emit(FavoritesState.from(store));
}
