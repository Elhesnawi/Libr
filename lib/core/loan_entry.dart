import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

/// استعارة مع كتابها واسم المستعير، جاهزة للعرض في الشاشات.
class LoanEntry {
  const LoanEntry({required this.loan, required this.book, required this.borrowerName});

  final Loan loan;
  final Book? book;
  final String borrowerName;

  String get title => book?.title ?? '';
}

extension LoanEntries on LibraryStore {
  LoanEntry entryOf(Loan loan) => LoanEntry(
        loan: loan,
        book: bookById(loan.bookId),
        borrowerName: userByName(loan.username)?.fullName ?? loan.username,
      );

  List<LoanEntry> entriesOf(Iterable<Loan> loans) => [for (final l in loans) entryOf(l)];
}
