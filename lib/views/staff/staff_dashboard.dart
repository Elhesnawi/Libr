import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/manage_screens.dart';
import 'package:librarry_app/views/staff/reports_screens.dart';
import 'package:librarry_app/views/staff/scan_screen.dart';
import 'package:librarry_app/views/staff/staff_forms.dart';
import 'package:librarry_app/views/user/profile_view.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// لوحة الموظف (أمين المكتبة) والمدير. المدير يرى بطاقات إضافية.
class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser;
        if (user == null) return const SizedBox.shrink();
        final isAdmin = user.role == UserRole.admin;
        final stats = store.stats();
        final scheme = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;

        final tiles = <_TileData>[
          _TileData('إدارة الكتب', Icons.library_books_outlined, () => const ManageBooksScreen()),
          _TileData('إضافة كتاب', Icons.library_add_outlined, () => const BookFormScreen()),
          _TileData('الأقسام', Icons.folder_copy_outlined, () => const CategoriesScreen()),
          _TileData('الاستعارات', Icons.swap_horiz, () => const LoansManageScreen()),
          _TileData('مسح الباركود', Icons.qr_code_scanner, () => const ScanScreen()),
          _TileData('طلبات الكتب', Icons.lightbulb_outline, () => const RequestsManageScreen(),
              badge: stats.pendingRequests),
          _TileData('الإعلانات', Icons.campaign_outlined, () => const AnnouncementsScreen()),
          _TileData('سجل النشاط', Icons.list_alt_outlined, () => const ActivityLogScreen()),
          if (isAdmin) ...[
            _TileData('الحسابات', Icons.group_outlined, () => const UsersScreen()),
            _TileData('الإحصائيات', Icons.bar_chart, () => const StatsScreen()),
            _TileData('التقارير', Icons.assessment_outlined, () => const ReportsScreen()),
          ],
          _TileData('حسابي', Icons.person_outline, () => const ProfileScreen()),
        ];

        return Scaffold(
          appBar: LibraryAppBar(title: isAdmin ? 'لوحة المدير' : 'لوحة أمين المكتبة'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً، ${user.fullName}',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(user.role.label,
                        style: TextStyle(color: scheme.onPrimaryContainer)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _Stat(label: 'الكتب', value: '${stats.books}')),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Stat(
                            label: 'استعارات نشطة',
                            value: '${stats.activeLoans}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Stat(
                            label: 'متأخرة',
                            value: '${stats.lateLoans}',
                            danger: stats.lateLoans > 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  for (final t in tiles)
                    _Tile(data: t, onTap: () => openScreen(context, t.build())),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                onPressed: () => logoutUser(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TileData {
  _TileData(this.title, this.icon, this.build, {this.badge = 0});

  final String title;
  final IconData icon;
  final Widget Function() build;
  final int badge;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.data, required this.onTap});

  final _TileData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data.icon, size: 30, color: scheme.primary),
                  const SizedBox(height: 6),
                  Text(data.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (data.badge > 0)
              PositionedDirectional(
                top: 8,
                start: 8,
                child: Badge(label: Text('${data.badge}')),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.danger = false});

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: danger ? scheme.error : null,
                ),
          ),
        ],
      ),
    );
  }
}
