import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class ActivityLogState {
  const ActivityLogState({required this.logs});

  final List<LogEntry> logs;

  factory ActivityLogState.from(LibraryStore s) => ActivityLogState(logs: s.logs);
}
