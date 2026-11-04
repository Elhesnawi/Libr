import 'package:librarry_app/core/loan_entry.dart';
import 'package:librarry_app/services/library_store.dart';

class LoansManageState {
  const LoansManageState({required this.entries});

  final List<LoanEntry> entries;

  factory LoansManageState.from(LibraryStore s) =>
      LoansManageState(entries: s.entriesOf(s.allActiveLoans));
}
