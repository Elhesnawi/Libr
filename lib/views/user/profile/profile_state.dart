import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class ProfileState {
  const ProfileState({
    required this.user,
    required this.darkMode,
    required this.loansCount,
    required this.favoritesCount,
  });

  final AppUser? user;
  final bool darkMode;

  /// عدد الكتب المستعارة حالياً (للمستخدم العادي).
  final int loansCount;

  /// عدد الكتب المفضلة (للمستخدم العادي).
  final int favoritesCount;

  factory ProfileState.from(LibraryStore s) {
    final user = s.currentUser;
    return ProfileState(
      user: user,
      darkMode: s.darkMode,
      loansCount: user == null ? 0 : s.activeLoansOf(user.username).length,
      favoritesCount: user == null ? 0 : s.favoritesCount,
    );
  }
}
