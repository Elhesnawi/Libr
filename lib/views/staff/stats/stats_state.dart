import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class StatsState {
  const StatsState({required this.stats, required this.perCategory, required this.maxCount});

  final LibraryStats stats;

  /// عدد الكتب في كل قسم.
  final List<MapEntry<String, int>> perCategory;
  final int maxCount;

  factory StatsState.from(LibraryStore s) {
    final counts = [
      for (final c in s.categories) MapEntry(c.name, s.search(categoryId: c.id).length),
    ];
    var max = 0;
    for (final e in counts) {
      if (e.value > max) max = e.value;
    }
    return StatsState(stats: s.stats(), perCategory: counts, maxCount: max);
  }
}
