import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/loans_manage/loans_manage_state.dart';

class LoansManageCubit extends StoreCubit<LoansManageState> {
  LoansManageCubit() : super(LoansManageState.from(LibraryStore.instance));

  @override
  void refresh() => emit(LoansManageState.from(store));

  void returnLoan(int loanId) => store.returnLoan(loanId);

  void extend(int loanId) => store.extendLoan(loanId);
}
