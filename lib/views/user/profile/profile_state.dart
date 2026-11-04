import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class ProfileState {
  const ProfileState({required this.user, required this.darkMode});

  final AppUser? user;
  final bool darkMode;

  factory ProfileState.from(LibraryStore s) =>
      ProfileState(user: s.currentUser, darkMode: s.darkMode);
}
