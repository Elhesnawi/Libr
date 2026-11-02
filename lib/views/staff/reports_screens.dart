import 'package:flutter/material.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.danger = false});

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: danger ? scheme.error : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.label, required this.value, required this.max});

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: max == 0 ? 0 : value / max,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// إحصائيات سريعة (للمدير).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: const LibraryAppBar(title: 'الإحصائيات'),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final s = store.stats();
          final counts = [
            for (final c in store.categories) MapEntry(c.name, store.search(categoryId: c.id).length),
          ];
          var max = 0;
          for (final e in counts) {
            if (e.value > max) max = e.value;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.9,
                children: [
                  _Metric(label: 'الكتب', value: '${s.books}'),
                  _Metric(label: 'استعارات نشطة', value: '${s.activeLoans}'),
                  _Metric(label: 'متأخرة', value: '${s.lateLoans}', danger: s.lateLoans > 0),
                  _Metric(label: 'الحسابات', value: '${s.users}'),
                ],
              ),
              const SectionTitle('الكتب حسب القسم'),
              for (final e in counts) _BarRow(label: e.key, value: e.value, max: max),
            ],
          );
        },
      ),
    );
  }
}

/// التقارير (للمدير): الأكثر استعارة، الشهري، المتأخرون، وتصدير.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: const LibraryAppBar(title: 'التقارير'),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final top = store.topBooks();
          final topMax = top.isEmpty ? 0 : top.first.value;
          final months = store.monthlyLoans();
          var monthMax = 1;
          for (final m in months) {
            if (m.value > monthMax) monthMax = m.value;
          }
          final late = store.lateLoans;
          final scheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('تصدير PDF'),
                      onPressed: () => runAction(
                        context,
                        () => store.logExport('PDF'),
                        success: 'تم إنشاء تقرير PDF (محاكاة)',
                        ms: 1500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('تصدير Excel'),
                      onPressed: () => runAction(
                        context,
                        () => store.logExport('Excel'),
                        success: 'تم إنشاء تقرير Excel (محاكاة)',
                        ms: 1500,
                      ),
                    ),
                  ),
                ],
              ),
              const SectionTitle('الكتب الأكثر استعارة'),
              for (final e in top) _BarRow(label: e.key.title, value: e.value, max: topMax),
              const SectionTitle('الاستعارات الشهرية'),
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final m in months)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${m.value}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 2),
                            Container(
                              height: 80.0 * m.value / monthMax,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(m.key, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SectionTitle('المتأخرون عن الإرجاع'),
              if (late.isEmpty)
                const EmptyState(message: 'لا يوجد متأخرون', icon: Icons.check_circle_outline),
              for (final l in late)
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: ListTile(
                    title: Text(store.bookById(l.bookId)?.title ?? ''),
                    subtitle: Text(store.userByName(l.username)?.fullName ?? l.username),
                    trailing: StatusChip.forLoan(l),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
