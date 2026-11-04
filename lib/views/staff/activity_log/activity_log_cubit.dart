import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/activity_log/activity_log_state.dart';

class ActivityLogCubit extends StoreCubit<ActivityLogState> {
  ActivityLogCubit() : super(ActivityLogState.from(LibraryStore.instance));

  @override
  void refresh() => emit(ActivityLogState.from(store));
}
