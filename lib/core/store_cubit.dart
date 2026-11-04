import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/library_store.dart';

/// أساس كل الـ Cubits: يستمع لتغيّر بيانات [LibraryStore] ويعيد بناء الحالة.
///
/// الـ Cubit لا يحتفظ بالبيانات، بل يبني منها حالة (State) جديدة عند كل تغيير.
/// عند ربط Supabase لاحقاً يتغير داخل [LibraryStore] فقط ولا تتغير الـ Cubits.
abstract class StoreCubit<S> extends Cubit<S> {
  StoreCubit(super.initialState) {
    store.addListener(refresh);
  }

  final LibraryStore store = LibraryStore.instance;

  /// يعيد بناء الحالة من المخزن مع الحفاظ على اختيارات الواجهة (state الحالية).
  void refresh();

  @override
  Future<void> close() {
    store.removeListener(refresh);
    return super.close();
  }
}
