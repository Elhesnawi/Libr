import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/credential_store.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth, {CredentialStore? credentials})
      : _credentials = credentials ?? SecureCredentialStore(),
        super(const LoginState());

  final AuthCubit _auth;
  final CredentialStore _credentials;

  void toggleObscure() => emit(state.copyWith(obscure: !state.obscure));

  void setRemember(bool value) => emit(state.copyWith(remember: value));

  /// يقرأ بيانات الدخول المحفوظة (إن وُجدت) ويفعّل خيار التذكّر.
  /// تعيدها الدالة لتملأ الشاشة الحقول.
  Future<SavedCredentials?> loadSaved() async {
    final saved = await _credentials.read();
    if (saved != null && !isClosed) emit(state.copyWith(remember: true));
    return saved;
  }

  /// عند النجاح يستبدل RootGate الشاشة تلقائياً، وعند الفشل تظهر الرسالة.
  /// يُحفظ الاسم وكلمة المرور فقط بعد نجاح الدخول وعند تفعيل التذكّر،
  /// ويُمسح المحفوظ إذا أُلغي الخيار.
  Future<void> submit(String username, String password) async {
    final remember = state.remember;
    emit(LoginState(obscure: state.obscure, remember: remember));
    try {
      _auth.login(username, password);
    } on LibraryException catch (e) {
      if (!isClosed) {
        emit(LoginState(obscure: state.obscure, remember: remember, error: e.message));
      }
      return;
    }
    if (remember) {
      await _credentials.save(username.trim(), password);
    } else {
      await _credentials.clear();
    }
  }
}
