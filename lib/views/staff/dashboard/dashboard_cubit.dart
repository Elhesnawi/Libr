import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/dashboard/dashboard_state.dart';

class DashboardCubit extends StoreCubit<DashboardState> {
  DashboardCubit() : super(DashboardState.from(LibraryStore.instance));

  @override
  void refresh() => emit(DashboardState.from(store));
}
