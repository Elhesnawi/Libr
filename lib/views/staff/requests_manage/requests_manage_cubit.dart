import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/requests_manage/requests_manage_state.dart';

class RequestsManageCubit extends StoreCubit<RequestsManageState> {
  RequestsManageCubit() : super(RequestsManageState.from(LibraryStore.instance));

  @override
  void refresh() => emit(RequestsManageState.from(store));

  void decide(int requestId, {required bool accepted}) =>
      store.decideRequest(requestId, accepted: accepted);
}
