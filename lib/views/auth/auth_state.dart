import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

/// حالة الجلسة على مستوى التطبيق: المستخدم الحالي والمظهر.
class AuthState {
  const AuthState({this.user, this.darkMode = false, this.previousLogin});

  final AppUser? user;
  final bool darkMode;
  final DateTime? previousLogin;

  factory AuthState.from(LibraryStore store) => AuthState(
        user: store.currentUser,
        darkMode: store.darkMode,
        previousLogin: store.previousLogin,
      );
}
