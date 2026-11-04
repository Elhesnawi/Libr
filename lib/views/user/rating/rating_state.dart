import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

/// تقييم مع اسم صاحبه جاهزاً للعرض.
class RatingEntry {
  const RatingEntry({required this.rating, required this.name});

  final Rating rating;
  final String name;
}

class RatingState {
  const RatingState({
    required this.entries,
    required this.average,
    required this.canRate,
    required this.isStaff,
    required this.isDigital,
    required this.mine,
    required this.stars,
  });

  final List<RatingEntry> entries;
  final double average;
  final bool canRate;
  final bool isStaff;
  final bool isDigital;
  final Rating? mine;

  /// عدد النجوم المختار الآن في الواجهة (قبل الحفظ).
  final int stars;

  factory RatingState.from(LibraryStore s, int bookId, {int? stars}) {
    final mine = s.myRating(bookId);
    return RatingState(
      entries: [
        for (final r in s.ratingsOf(bookId))
          RatingEntry(rating: r, name: s.userByName(r.username)?.fullName ?? r.username),
      ],
      average: s.averageRating(bookId),
      canRate: s.canRate(bookId),
      isStaff: s.currentUser?.role.isStaff ?? false,
      isDigital: s.bookById(bookId)?.isDigital ?? false,
      mine: mine,
      stars: stars ?? mine?.stars ?? 0,
    );
  }
}
