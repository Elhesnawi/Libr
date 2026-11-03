import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/users/users_state.dart';

class UsersCubit extends StoreCubit<UsersState> {
  UsersCubit() : super(UsersState.from(LibraryStore.instance));

  @override
  void refresh() => emit(UsersState.from(store));

  /// يرمي [LibraryException] عند تغيير دور حسابك أو إزالة آخر مدير.
  void setRole(String username, UserRole role) => store.setRole(username, role);
}
