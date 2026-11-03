import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class UsersState {
  const UsersState({required this.users, required this.meUsername});

  final List<AppUser> users;
  final String? meUsername;

  factory UsersState.from(LibraryStore s) =>
      UsersState(users: s.users, meUsername: s.currentUser?.username);
}
