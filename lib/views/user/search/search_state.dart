import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';

class SearchState {
  const SearchState({
    required this.query,
    required this.categoryId,
    required this.type,
    required this.results,
    required this.categories,
  });

  final String query;
  final int? categoryId;
  final LibraryType? type;
  final List<Book> results;
  final List<BookCategory> categories;

  factory SearchState.from(
    LibraryStore s, {
    String query = '',
    int? categoryId,
    LibraryType? type,
  }) =>
      SearchState(
        query: query,
        categoryId: categoryId,
        type: type,
        results: s.search(query: query, categoryId: categoryId, type: type),
        categories: s.categories,
      );
}
