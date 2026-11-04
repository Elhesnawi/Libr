import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/shell/shell_state.dart';

class ShellCubit extends StoreCubit<ShellState> {
  ShellCubit() : super(ShellState(unread: _unread(LibraryStore.instance)));

  static int _unread(LibraryStore s) {
    final user = s.currentUser;
    return user == null ? 0 : s.unreadCount(user.username);
  }

  void select(int index) => emit(ShellState(index: index, unread: _unread(store)));

  @override
  void refresh() => emit(ShellState(index: state.index, unread: _unread(store)));
}
