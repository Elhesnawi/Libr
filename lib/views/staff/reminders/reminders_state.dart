import 'package:librarry_app/core/loan_entry.dart';
import 'package:librarry_app/services/library_store.dart';

class RemindersState {
  const RemindersState({required this.entries});

  final List<LoanEntry> entries;

  factory RemindersState.from(LibraryStore s) =>
      RemindersState(entries: s.entriesOf(s.remindableLoans));
}
