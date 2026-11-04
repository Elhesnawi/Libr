import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/stats/stats_state.dart';

class StatsCubit extends StoreCubit<StatsState> {
  StatsCubit() : super(StatsState.from(LibraryStore.instance));

  @override
  void refresh() => emit(StatsState.from(store));
}
