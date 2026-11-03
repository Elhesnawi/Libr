import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/views/user/category_books/category_books_cubit.dart';
import 'package:librarry_app/views/user/category_books/category_books_state.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// كتب قسم معين (ورقية أو رقمية حسب الاختيار في الرئيسية).
class CategoryBooksScreen extends StatelessWidget {
  const CategoryBooksScreen({super.key, required this.category, required this.type});

  final BookCategory category;
  final LibraryType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBooksCubit(category.id, type),
      child: Scaffold(
        appBar: LibraryAppBar(title: category.name),
        body: BlocBuilder<CategoryBooksCubit, CategoryBooksState>(
          builder: (context, state) => ListView(
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
                books: state.books,
                emptyMessage: 'لا توجد كتب في هذا القسم',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
