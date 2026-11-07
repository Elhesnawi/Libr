import 'package:librarry_app/models/category_shelf.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';

class HomeState {
  const HomeState({
    required this.user,
    required this.previousLogin,
    required this.loans,
    required this.nextTitle,
    required this.announcement,
    required this.query,
    required this.results,
    required this.hasActivity,
    required this.suggestions,
    required this.digital,
    required this.paper,
  });

  final AppUser? user;
  final DateTime? previousLogin;
  final List<Loan> loans;
  final String? nextTitle;
  final Announcement? announcement;
  final String query;
  final List<Book> results;
  final bool hasActivity;
  final List<Book> suggestions;
  final LibrarySectionData digital;
  final LibrarySectionData paper;

  Loan? get nextLoan => loans.isEmpty ? null : loans.first;

  factory HomeState.from(
    LibraryStore s, {
    String query = '',
    int? digitalCategoryId,
    int? paperCategoryId,
  }) {
    final user = s.currentUser;
    final loans = user == null ? <Loan>[] : s.activeLoansOf(user.username);
    final announcements = s.announcements;
    return HomeState(
      user: user,
      previousLogin: s.previousLogin,
      loans: loans,
      nextTitle: loans.isEmpty ? null : s.bookById(loans.first.bookId)?.title,
      announcement: announcements.isEmpty ? null : announcements.first,
      query: query,
      results: query.trim().isEmpty ? <Book>[] : s.search(query: query).take(5).toList(),
      hasActivity: user != null && s.hasActivity(user.username),
      suggestions: user == null ? <Book>[] : s.suggestionsFor(user.username),
      digital: _section(s, LibraryType.digital, digitalCategoryId),
      paper: _section(s, LibraryType.paper, paperCategoryId),
    );
  }

  /// الأقسام التي فيها كتب من هذا النوع فقط، مع القسم المختار.
  static LibrarySectionData _section(LibraryStore s, LibraryType type, int? selectedId) {
    final shelves = <CategoryShelf>[
      for (final c in s.categories)
        if (s.booksIn(c.id, type).isNotEmpty) CategoryShelf(c, s.booksIn(c.id, type)),
    ];
    return LibrarySectionData(type: type, shelves: shelves, selectedId: selectedId);
  }
}
