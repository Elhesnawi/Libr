import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/activity_log/activity_log_cubit.dart';
import 'package:librarry_app/views/staff/activity_log/activity_log_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityLogCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'سجل النشاط'),
        body: BlocBuilder<ActivityLogCubit, ActivityLogState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.logs.isEmpty) const EmptyState(message: 'لا توجد عمليات'),
              for (final l in state.logs)
                SoftCard(
                  child: ListTile(
                    dense: true,
                    title: Text(l.message),
                    subtitle: Text('${l.username} · ${arabicDayAndTime(l.at)}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
