import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';

class CategoryBooksState {
  const CategoryBooksState({required this.books});

  final List<Book> books;

  factory CategoryBooksState.from(LibraryStore s, int categoryId, LibraryType type) =>
      CategoryBooksState(books: s.booksIn(categoryId, type));
}
