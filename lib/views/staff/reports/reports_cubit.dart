import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/reports/reports_state.dart';

class ReportsCubit extends StoreCubit<ReportsState> {
  ReportsCubit() : super(ReportsState.from(LibraryStore.instance));

  @override
  void refresh() => emit(ReportsState.from(store));

  /// [format] إما PDF أو Excel (محاكاة حالياً).
  void export(String format) => store.logExport(format);
}
