import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/notifications/notifications_cubit.dart';
import 'package:librarry_app/views/user/notifications/notifications_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'الإشعارات'),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              return const EmptyState(
                message: 'لا توجد إشعارات',
                icon: Icons.notifications_none,
              );
            }
            final scheme = Theme.of(context).colorScheme;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in state.items)
                  SoftCard(
                    child: ListTile(
                      leading: Icon(
                        item.fresh
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: item.fresh ? scheme.primary : null,
                      ),
                      title: Text(item.notification.title),
                      subtitle: Text(
                        '${item.notification.subtitle} · ${arabicDayAndTime(item.notification.createdAt)}',
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
