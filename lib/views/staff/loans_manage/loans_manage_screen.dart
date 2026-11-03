import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/loans_manage/loans_manage_cubit.dart';
import 'package:librarry_app/views/staff/loans_manage/loans_manage_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class LoansManageScreen extends StatelessWidget {
  const LoansManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoansManageCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'إدارة الاستعارات'),
        body: BlocBuilder<LoansManageCubit, LoansManageState>(
          builder: (context, state) {
            if (state.entries.isEmpty) {
              return const EmptyState(message: 'لا توجد استعارات حالية');
            }
            final cubit = context.read<LoansManageCubit>();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final e in state.entries)
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
                                  e.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              StatusChip.forLoan(e.loan),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'المستعير: ${e.borrowerName} · الإرجاع: ${arabicDate(e.loan.dueAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FilledButton.tonal(
                                onPressed: () => runAction(
                                  context,
                                  () => cubit.returnLoan(e.loan.id),
                                  success: 'تم تسجيل الإرجاع',
                                ),
                                child: const Text('تسجيل إرجاع'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => runAction(
                                  context,
                                  () => cubit.extend(e.loan.id),
                                  success: 'تم التمديد ${LibraryStore.extendDays} أيام',
                                  ms: 600,
                                ),
                                child: Text('تمديد ${LibraryStore.extendDays} أيام'),
                              ),
                            ],
                          ),
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
