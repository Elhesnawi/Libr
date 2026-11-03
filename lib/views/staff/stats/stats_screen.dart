import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/staff/stats/stats_cubit.dart';
import 'package:librarry_app/views/staff/stats/stats_state.dart';
import 'package:librarry_app/widgets/bar_row.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/metric_box.dart';

/// إحصائيات سريعة (للمدير).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'الإحصائيات'),
        body: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            final s = state.stats;
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
                    MetricBox(label: 'الكتب', value: '${s.books}'),
                    MetricBox(label: 'استعارات نشطة', value: '${s.activeLoans}'),
                    MetricBox(label: 'متأخرة', value: '${s.lateLoans}', danger: s.lateLoans > 0),
                    MetricBox(label: 'الحسابات', value: '${s.users}'),
                  ],
                ),
                const SectionTitle('الكتب حسب القسم'),
                for (final e in state.perCategory)
                  BarRow(label: e.key, value: e.value, max: state.maxCount),
              ],
            );
          },
        ),
      ),
    );
  }
}
