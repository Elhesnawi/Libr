import 'package:flutter/material.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// سجل الاستعارات السابقة (التي أُعيدت).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: const LibraryAppBar(title: 'سجل الاستعارات'),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final user = store.currentUser;
          if (user == null) return const SizedBox.shrink();
          final history = store.historyOf(user.username);
          if (history.isEmpty) {
            return const EmptyState(
              message: 'لا توجد استعارات سابقة',
              icon: Icons.history,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final loan in history)
                if (store.bookById(loan.bookId) != null)
                  BookTile(
                    book: store.bookById(loan.bookId)!,
                    trailing: Text(
                      'أُعيد ${arabicDate(loan.returnedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
