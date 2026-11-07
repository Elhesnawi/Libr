class LoginState {
  const LoginState({this.obscure = true, this.error, this.remember = false});

  /// إخفاء كلمة المرور.
  final bool obscure;

  /// رسالة الخطأ الظاهرة تحت الحقول.
  final String? error;

  /// خيار «تذكّر كلمة المرور».
  final bool remember;

  LoginState copyWith({bool? obscure, bool? remember}) => LoginState(
        obscure: obscure ?? this.obscure,
        error: error,
        remember: remember ?? this.remember,
      );
}
