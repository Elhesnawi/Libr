import 'package:flutter/material.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';

/// استعاراتي الحالية مع موعد الإرجاع.
class LoansTab extends StatelessWidget {
  const LoansTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => _content(store),
    );
  }

  Widget _content(LibraryStore store) {
    final user = store.currentUser;
    if (user == null) return const SizedBox.shrink();
    final loans = store.activeLoansOf(user.username);
    if (loans.isEmpty) {
      return const EmptyState(
        message: 'لا توجد استعارات حالية',
        icon: Icons.menu_book_outlined,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final loan in loans)
          if (store.bookById(loan.bookId) != null)
            BookTile(
              book: store.bookById(loan.bookId)!,
              trailing: StatusChip.forLoan(loan),
            ),
      ],
    );
  }
}

/// الكتب المفضلة للمستخدم.
class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LibraryStore.instance,
      builder: (context, _) => _content(),
    );
  }

  Widget _content() {
    final books = LibraryStore.instance.favoriteBooks();
    if (books.isEmpty) {
      return const EmptyState(
        message: 'لم تضف كتباً إلى المفضلة بعد',
        icon: Icons.bookmark_border,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [for (final b in books) BookTile(book: b)],
    );
  }
}
