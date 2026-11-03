import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class NotificationItem {
  const NotificationItem({required this.notification, required this.fresh});

  final AppNotification notification;

  /// كان غير مقروء عند فتح الشاشة (يُميَّز بنقطة).
  final bool fresh;
}

class NotificationsState {
  const NotificationsState({required this.items});

  final List<NotificationItem> items;

  factory NotificationsState.from(LibraryStore s, Set<int> freshIds) {
    final user = s.currentUser;
    if (user == null) return const NotificationsState(items: []);
    return NotificationsState(
      items: [
        for (final n in s.notificationsOf(user.username))
          NotificationItem(notification: n, fresh: freshIds.contains(n.id)),
      ],
    );
  }
}
