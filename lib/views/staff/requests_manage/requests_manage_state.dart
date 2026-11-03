import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class RequestRow {
  const RequestRow({required this.request, required this.requesterName});

  final BookRequest request;
  final String requesterName;
}

class RequestsManageState {
  const RequestsManageState({required this.rows});

  final List<RequestRow> rows;

  factory RequestsManageState.from(LibraryStore s) => RequestsManageState(
        rows: [
          for (final r in s.allRequests)
            RequestRow(
              request: r,
              requesterName: s.userByName(r.username)?.fullName ?? r.username,
            ),
        ],
      );
}
