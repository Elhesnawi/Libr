import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/loans/loans_state.dart';

class LoansCubit extends StoreCubit<LoansState> {
  LoansCubit() : super(LoansState.from(LibraryStore.instance));

  @override
  void refresh() => emit(LoansState.from(store));
}
