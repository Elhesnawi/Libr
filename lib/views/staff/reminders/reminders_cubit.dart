import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/reminders/reminders_state.dart';

class RemindersCubit extends StoreCubit<RemindersState> {
  RemindersCubit() : super(RemindersState.from(LibraryStore.instance));

  @override
  void refresh() => emit(RemindersState.from(store));

  void remindAll() => store.remindAllDue();

  void remind(int loanId) => store.remindLoan(loanId);
}
