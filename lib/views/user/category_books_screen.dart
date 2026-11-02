import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// كتب قسم معين (ورقية أو رقمية حسب الاختيار في الرئيسية).
class CategoryBooksScreen extends StatelessWidget {
  const CategoryBooksScreen({super.key, required this.category, required this.type});

  final BookCategory category;
  final LibraryType type;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: LibraryAppBar(title: category.name),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                type == LibraryType.digital ? 'الكتب الرقمية' : 'المكتبة الورقية',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            BookList(
              books: store.booksIn(category.id, type),
              emptyMessage: 'لا توجد كتب في هذا القسم',
            ),
          ],
        ),
      ),
    );
  }
}
