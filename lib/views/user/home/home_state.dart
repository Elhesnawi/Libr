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
    required this.type,
    required this.categories,
    required this.counts,
    required this.favoritesCount,
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
  final LibraryType type;
  final List<BookCategory> categories;
  final Map<int, int> counts;
  final int favoritesCount;

  Loan? get nextLoan => loans.isEmpty ? null : loans.first;

  factory HomeState.from(
    LibraryStore s, {
    required LibraryType type,
    String query = '',
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
      type: type,
      categories: s.categories,
      counts: {for (final c in s.categories) c.id: s.countIn(c.id, type)},
      favoritesCount: user == null ? 0 : s.favoritesCount,
    );
  }
}
