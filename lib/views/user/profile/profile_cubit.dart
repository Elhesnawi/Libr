import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/profile/profile_state.dart';

class ProfileCubit extends StoreCubit<ProfileState> {
  ProfileCubit() : super(ProfileState.from(LibraryStore.instance));

  void setDarkMode(bool value) => store.setDarkMode(value);

  /// أداة للتجربة فقط: تقدّم الوقت يوماً لرؤية التنبيهات الجديدة.
  void simulateDayPassed() => store.simulateDayPassed();

  @override
  void refresh() => emit(ProfileState.from(store));
}
