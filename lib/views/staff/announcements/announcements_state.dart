import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class AnnouncementsState {
  const AnnouncementsState({required this.announcements});

  final List<Announcement> announcements;

  factory AnnouncementsState.from(LibraryStore s) =>
      AnnouncementsState(announcements: s.announcements);
}
