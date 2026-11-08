import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/profile/profile_state.dart';

class ProfileCubit extends StoreCubit<ProfileState> {
  ProfileCubit() : super(ProfileState.from(LibraryStore.instance));

  /// يحفظ جهة العمل ورقم الهاتف. يرمي [LibraryException] عند إدخال غير صالح.
  void saveAccountData({
    required OrgKind? kind,
    required List<String> values,
    required String phone,
  }) =>
      store.updateProfile(kind: kind, values: values, phone: phone);

  /// أداة للتجربة فقط: تقدّم الوقت يوماً لرؤية التنبيهات الجديدة.
  void simulateDayPassed() => store.simulateDayPassed();

  @override
  void refresh() => emit(ProfileState.from(store));
}
