import 'package:librarry_app/core/loan_entry.dart';
import 'package:librarry_app/services/library_store.dart';

class LoansState {
  const LoansState({required this.entries});

  final List<LoanEntry> entries;

  factory LoansState.from(LibraryStore s) {
    final user = s.currentUser;
    return LoansState(
      entries: user == null ? const [] : s.entriesOf(s.activeLoansOf(user.username)),
    );
  }
}
