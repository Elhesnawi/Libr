import 'package:librarry_app/core/loan_entry.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class ReportsState {
  const ReportsState({
    required this.top,
    required this.topMax,
    required this.months,
    required this.monthMax,
    required this.late,
    required this.rated,
  });

  final List<MapEntry<Book, int>> top;
  final int topMax;
  final List<MapEntry<String, int>> months;
  final int monthMax;
  final List<LoanEntry> late;
  final List<MapEntry<Book, double>> rated;

  factory ReportsState.from(LibraryStore s) {
    final top = s.topBooks();
    final months = s.monthlyLoans();
    var monthMax = 1;
    for (final m in months) {
      if (m.value > monthMax) monthMax = m.value;
    }
    return ReportsState(
      top: top,
      topMax: top.isEmpty ? 0 : top.first.value,
      months: months,
      monthMax: monthMax,
      late: s.entriesOf(s.lateLoans),
      rated: s.topRated(),
    );
  }
}
