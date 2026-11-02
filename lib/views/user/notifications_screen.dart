import 'package:flutter/material.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// الإشعارات التي كانت غير مقروءة عند فتح الشاشة (لتمييزها بنقطة).
  final Set<int> _freshIds = {};

  @override
  void initState() {
    super.initState();
    final store = LibraryStore.instance;
    final user = store.currentUser;
    if (user != null) {
      for (final n in store.notificationsOf(user.username)) {
        if (!n.read) _freshIds.add(n.id);
      }
      // تعليمها كمقروءة بعد أول إطار حتى لا نغيّر المخزن أثناء البناء.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        store.markAllRead(user.username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: const LibraryAppBar(title: 'الإشعارات'),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final user = store.currentUser;
          if (user == null) return const SizedBox.shrink();
          final list = store.notificationsOf(user.username);
          if (list.isEmpty) {
            return const EmptyState(
              message: 'لا توجد إشعارات',
              icon: Icons.notifications_none,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final n in list)
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  child: ListTile(
                    leading: Icon(
                      _freshIds.contains(n.id)
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: _freshIds.contains(n.id)
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(n.title),
                    subtitle: Text('${n.subtitle} · ${arabicDayAndTime(n.createdAt)}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
