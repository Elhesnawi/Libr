import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/staff/reports/reports_cubit.dart';
import 'package:librarry_app/views/staff/reports/reports_state.dart';
import 'package:librarry_app/widgets/bar_row.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';
import 'package:librarry_app/widgets/stars_view.dart';

/// التقارير (للمدير): الأكثر استعارة، الشهري، المتأخرون، وتصدير.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'التقارير'),
        body: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            final cubit = context.read<ReportsCubit>();
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
                        () => cubit.export('PDF'),
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
                        () => cubit.export('Excel'),
                        success: 'تم إنشاء تقرير Excel (محاكاة)',
                        ms: 1500,
                      ),
                    ),
                  ),
                ],
              ),
              const SectionTitle('الكتب الأكثر استعارة'),
              for (final e in state.top) BarRow(label: e.key.title, value: e.value, max: state.topMax),
              const SectionTitle('الأعلى تقييماً'),
              if (state.rated.isEmpty)
                const EmptyState(message: 'لا توجد تقييمات بعد', icon: Icons.star_border),
              for (final e in state.rated)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.key.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      StarsView(value: e.value, size: 13),
                      const SizedBox(width: 6),
                      Text(e.value.toStringAsFixed(1)),
                    ],
                  ),
                ),
              const SectionTitle('الاستعارات الشهرية'),
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final m in state.months)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${m.value}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 2),
                            Container(
                              height: 80.0 * m.value / state.monthMax,
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
              if (state.late.isEmpty)
                const EmptyState(message: 'لا يوجد متأخرون', icon: Icons.check_circle_outline),
              for (final l in state.late)
                SoftCard(
                  child: ListTile(
                    title: Text(l.title),
                    subtitle: Text(l.borrowerName),
                    trailing: StatusChip.forLoan(l.loan),
                  ),
                ),
            ],
          );
          },
        ),
      ),
    );
  }
}
