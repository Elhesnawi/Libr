import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/notifications/notifications_state.dart';

class NotificationsCubit extends StoreCubit<NotificationsState> {
  NotificationsCubit._(this._freshIds)
      : super(NotificationsState.from(LibraryStore.instance, _freshIds));

  /// الإشعارات التي كانت غير مقروءة عند فتح الشاشة.
  final Set<int> _freshIds;

  factory NotificationsCubit() {
    final s = LibraryStore.instance;
    final user = s.currentUser;
    final fresh = <int>{
      if (user != null)
        for (final n in s.notificationsOf(user.username))
          if (!n.read) n.id,
    };
    final cubit = NotificationsCubit._(fresh);
    // نعلّمها كمقروءة بعد الإنشاء حتى لا نغيّر المخزن أثناء البناء.
    Future.microtask(() {
      if (!cubit.isClosed && user != null) s.markAllRead(user.username);
    });
    return cubit;
  }

  @override
  void refresh() => emit(NotificationsState.from(store, _freshIds));
}
