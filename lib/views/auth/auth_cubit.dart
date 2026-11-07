import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/services/theme_preference.dart';
import 'package:librarry_app/views/auth/auth_state.dart';

/// الجلسة والمظهر. يُنشأ مرة واحدة في main ويستعمله RootGate وMaterialApp.
class AuthCubit extends StoreCubit<AuthState> {
  AuthCubit() : super(AuthState.from(LibraryStore.instance));

  @override
  void refresh() => emit(AuthState.from(store));

  /// يرمي [LibraryException] عند بيانات خاطئة.
  void login(String username, String password) => store.login(username, password);

  void logout() => store.logout();

  void setDarkMode(bool value) {
    store.setDarkMode(value);
    ThemePreference.save(value);
  }

  void toggleDarkMode() => setDarkMode(!store.darkMode);
}
