import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth) : super(const LoginState());

  final AuthCubit _auth;

  void toggleObscure() => emit(LoginState(obscure: !state.obscure, error: state.error));

  /// عند النجاح يستبدل RootGate الشاشة تلقائياً، وعند الفشل تظهر الرسالة.
  Future<void> submit(String username, String password) async {
    emit(LoginState(obscure: state.obscure));
    try {
      _auth.login(username, password);
    } on LibraryException catch (e) {
      if (!isClosed) emit(LoginState(obscure: state.obscure, error: e.message));
    }
  }
}
