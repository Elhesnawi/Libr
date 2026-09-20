abstract class LoginState {}

class InitLoginState extends LoginState {}

class SuccessLoginState extends LoginState {}

class LoadingLoginState extends LoginState {}

class ErrorLoginState extends LoginState{
  final String error;
  ErrorLoginState(this.error);
}