import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/history/history_state.dart';

class HistoryCubit extends StoreCubit<HistoryState> {
  HistoryCubit() : super(HistoryState.from(LibraryStore.instance));

  @override
  void refresh() => emit(HistoryState.from(store));
}
