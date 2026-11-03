import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class FavoritesState {
  const FavoritesState({required this.books});

  final List<Book> books;

  factory FavoritesState.from(LibraryStore s) =>
      FavoritesState(books: s.currentUser == null ? const [] : s.favoriteBooks());
}
