import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/staff/book_form/book_form_screen.dart';
import 'package:librarry_app/views/staff/manage_books/manage_books_cubit.dart';
import 'package:librarry_app/views/staff/manage_books/manage_books_state.dart';
import 'package:librarry_app/widgets/book_cover.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageBooksCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'إدارة الكتب'),
        body: BlocBuilder<ManageBooksCubit, ManageBooksState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة كتاب'),
                onPressed: () => openScreen(context, const BookFormScreen()),
              ),
              const SizedBox(height: 12),
              if (state.rows.isEmpty) const EmptyState(message: 'لا توجد كتب'),
              for (final row in state.rows) _BookCard(row: row),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.row});

  final BookRow row;

  @override
  Widget build(BuildContext context) {
    final b = row.book;
    return SoftCard(
      child: ListTile(
        leading: BookCover(book: b),
        title: Text(b.title),
        subtitle: Text(
          '${b.code} · ${row.categoryName} · '
          '${b.isDigital ? 'رقمي' : '${b.availableCopies}/${b.totalCopies}'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => openScreen(context, BookFormScreen(book: b)),
            ),
            IconButton(
              tooltip: 'حذف',
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              onPressed: () async {
                final cubit = context.read<ManageBooksCubit>();
                final yes = await confirmDialog(
                  context,
                  title: 'حذف الكتاب',
                  message: 'هل تريد حذف "${b.title}"؟',
                  confirmLabel: 'حذف',
                );
                if (!yes || !context.mounted) return;
                await runAction(
                  context,
                  () => cubit.delete(b.id),
                  success: 'تم حذف الكتاب',
                  ms: 600,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
