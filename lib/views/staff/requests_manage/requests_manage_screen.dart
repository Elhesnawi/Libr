import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/staff/requests_manage/requests_manage_cubit.dart';
import 'package:librarry_app/views/staff/requests_manage/requests_manage_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class RequestsManageScreen extends StatelessWidget {
  const RequestsManageScreen({super.key});

  static Tone _tone(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return Tone.warning;
      case RequestStatus.accepted:
        return Tone.success;
      case RequestStatus.rejected:
        return Tone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestsManageCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'طلبات الكتب'),
        body: BlocBuilder<RequestsManageCubit, RequestsManageState>(
          builder: (context, state) {
            if (state.rows.isEmpty) {
              return const EmptyState(
                message: 'لا توجد طلبات',
                icon: Icons.lightbulb_outline,
              );
            }
            final cubit = context.read<RequestsManageCubit>();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final row in state.rows)
                  SoftCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  row.request.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              StatusChip(
                                label: row.request.status.label,
                                tone: _tone(row.request.status),
                              ),
                            ],
                          ),
                          Text(
                            'المؤلف: ${row.request.author} · من: ${row.requesterName}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (row.request.status == RequestStatus.pending) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilledButton.tonal(
                                  onPressed: () => runAction(
                                    context,
                                    () => cubit.decide(row.request.id, accepted: true),
                                    success: 'تم قبول الطلب وإشعار المستخدم',
                                    ms: 600,
                                  ),
                                  child: const Text('قبول'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => runAction(
                                    context,
                                    () => cubit.decide(row.request.id, accepted: false),
                                    success: 'تم رفض الطلب وإشعار المستخدم',
                                    ms: 600,
                                  ),
                                  child: const Text('رفض'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
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
