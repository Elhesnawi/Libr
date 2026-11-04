import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class CategoryRow {
  const CategoryRow({required this.category, required this.bookCount});

  final BookCategory category;
  final int bookCount;
}

class CategoriesState {
  const CategoriesState({required this.rows, required this.isAdmin});

  final List<CategoryRow> rows;
  final bool isAdmin;

  factory CategoriesState.from(LibraryStore s) => CategoriesState(
        rows: [
          for (final c in s.categories)
            CategoryRow(category: c, bookCount: s.search(categoryId: c.id).length),
        ],
        isAdmin: s.currentUser?.role == UserRole.admin,
      );
}
