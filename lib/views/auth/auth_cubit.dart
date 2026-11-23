import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/services/remote_auth.dart';
import 'package:librarry_app/services/theme_preference.dart';
import 'package:librarry_app/views/auth/auth_state.dart';

/// الجلسة والمظهر. يُنشأ مرة واحدة في main ويستعمله RootGate وMaterialApp.
class AuthCubit extends StoreCubit<AuthState> {
  AuthCubit({RemoteAuth? remote})
      : _remote = remote,
        super(AuthState.from(LibraryStore.instance));

  /// الدخول عبر الخادم. إن كان فارغاً (اختبارات) يُستعمل الدخول المحلي.
  final RemoteAuth? _remote;

  bool get usesServer => _remote != null;

  @override
  void refresh() => emit(AuthState.from(store));

  /// يرمي [LibraryException] عند بيانات خاطئة.
  void login(String username, String password) => store.login(username, password);

  /// يدخل عبر الخادم إن وُجد، وإلا محلياً. يرمي [LibraryException] عند الفشل.
  Future<void> signIn(String username, String password) async {
    final remote = _remote;
    if (remote == null) {
      login(username, password);
      return;
    }
    store.loginRemote(await remote.signIn(username, password));
  }

  void logout() {
    store.logout();
    _remote?.signOut();
  }

  void setDarkMode(bool value) {
    store.setDarkMode(value);
    ThemePreference.save(value);
  }

  void toggleDarkMode() => setDarkMode(!store.darkMode);
}
