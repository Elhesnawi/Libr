import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/user_form/user_form_state.dart';

/// إنشاء حساب جديد (للمدير فقط) بكلمة مرور مؤقتة.
class UserFormCubit extends Cubit<UserFormState> {
  UserFormCubit() : super(const UserFormState(role: UserRole.user));

  void setRole(UserRole? role) {
    if (role != null) emit(UserFormState(role: role));
  }

  void save({required String username, required String fullName}) =>
      LibraryStore.instance.addUser(
        username: username,
        fullName: fullName,
        role: state.role,
      );
}
