import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class DashboardState {
  const DashboardState({
    required this.user,
    required this.stats,
    required this.remindable,
  });

  final AppUser? user;
  final LibraryStats stats;

  /// عدد الاستعارات التي تستحق تذكيراً (شارة بطاقة التذكيرات).
  final int remindable;

  bool get isAdmin => user?.role == UserRole.admin;

  factory DashboardState.from(LibraryStore s) => DashboardState(
        user: s.currentUser,
        stats: s.stats(),
        remindable: s.remindableLoans.length,
      );
}
