import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/api_service.dart';
import 'package:librarry_app/views/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.apiService}) : super(InitLoginState());
  final ApiService apiService;

  Future<void> login(String username,
   String password) async {
    emit(LoadingLoginState());
    var response = await apiService.login({
      'username': username,
      'password': password,
    });
    if (response['success']) {
      ///
      emit(SuccessLoginState());
      print(response['token']);
    } else {
      emit(ErrorLoginState(response['error']));
    }
  }
}
