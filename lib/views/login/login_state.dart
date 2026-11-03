class LoginState {
  const LoginState({this.obscure = true, this.error});

  /// إخفاء كلمة المرور.
  final bool obscure;

  /// رسالة الخطأ الظاهرة تحت الحقول.
  final String? error;
}
