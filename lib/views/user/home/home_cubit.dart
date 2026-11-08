import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/home/home_state.dart';

class HomeCubit extends StoreCubit<HomeState> {
  HomeCubit() : super(HomeState.from(LibraryStore.instance));

  /// القسم المختار في كل من الكتب الرقمية والمكتبة الورقية.
  int? _digitalCategoryId;
  int? _paperCategoryId;

  HomeState _build() => HomeState.from(
        store,
        digitalCategoryId: _digitalCategoryId,
        paperCategoryId: _paperCategoryId,
      );

  /// يغيّر القسم المختار فتتغير الكتب المعروضة تحته.
  void selectCategory(LibraryType type, int categoryId) {
    if (type == LibraryType.digital) {
      _digitalCategoryId = categoryId;
    } else {
      _paperCategoryId = categoryId;
    }
    emit(_build());
  }

  @override
  void refresh() => emit(_build());
}
