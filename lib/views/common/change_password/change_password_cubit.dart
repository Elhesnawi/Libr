import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/common/change_password/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(const ChangePasswordState());

  /// يعيد false ويعرض الخطأ إذا لم تتطابق كلمتا المرور الجديدتان.
  bool validate(String newPassword, String confirm) {
    if (newPassword != confirm) {
      emit(const ChangePasswordState(error: 'كلمتا المرور الجديدتان غير متطابقتين'));
      return false;
    }
    emit(const ChangePasswordState());
    return true;
  }

  void showError(String message) => emit(ChangePasswordState(error: message));

  /// يرمي [LibraryException] عند كلمة مرور خاطئة أو قصيرة.
  void save(String oldPassword, String newPassword) =>
      LibraryStore.instance.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
}
