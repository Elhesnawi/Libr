import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';

/// كتب قسم واحد (رفّ) داخل قسم رئيسي: الكتب الرقمية أو المكتبة الورقية.
class CategoryShelf {
  const CategoryShelf(this.category, this.books);

  final BookCategory category;
  final List<Book> books;
}

/// بيانات قسم رئيسي في الشاشة الرئيسية: الرفوف (الأقسام التي فيها كتب)
/// والقسم المختار حالياً.
class LibrarySectionData {
  const LibrarySectionData({
    required this.type,
    required this.shelves,
    required this.selectedId,
  });

  final LibraryType type;
  final List<CategoryShelf> shelves;
  final int? selectedId;

  /// القسم المختار، أو أول قسم إن لم يكن المختار صالحاً.
  CategoryShelf? get selected {
    if (shelves.isEmpty) return null;
    for (final s in shelves) {
      if (s.category.id == selectedId) return s;
    }
    return shelves.first;
  }
}
