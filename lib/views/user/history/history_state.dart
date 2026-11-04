import 'package:librarry_app/core/loan_entry.dart';
import 'package:librarry_app/services/library_store.dart';

class HistoryState {
  const HistoryState({required this.entries});

  final List<LoanEntry> entries;

  factory HistoryState.from(LibraryStore s) {
    final user = s.currentUser;
    return HistoryState(
      entries: user == null ? const [] : s.entriesOf(s.historyOf(user.username)),
    );
  }
}
