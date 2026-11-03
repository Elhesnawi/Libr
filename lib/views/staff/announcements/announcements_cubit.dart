import 'package:librarry_app/core/store_cubit.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/announcements/announcements_state.dart';

class AnnouncementsCubit extends StoreCubit<AnnouncementsState> {
  AnnouncementsCubit() : super(AnnouncementsState.from(LibraryStore.instance));

  @override
  void refresh() => emit(AnnouncementsState.from(store));

  void publish(String text) => store.addAnnouncement(text);

  void delete(int id) => store.deleteAnnouncement(id);
}
