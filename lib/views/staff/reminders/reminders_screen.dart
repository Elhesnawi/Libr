import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/reminders/reminders_cubit.dart';
import 'package:librarry_app/views/staff/reminders/reminders_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RemindersCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'التذكيرات'),
        body: BlocBuilder<RemindersCubit, RemindersState>(
          builder: (context, state) {
            final cubit = context.read<RemindersCubit>();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'المتأخرون ومن يحين موعد إرجاعهم اليوم أو غداً. يصلهم تنبيه تلقائي '
                  'عند الدخول، ويمكنك إرسال تذكير يدوي.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                if (state.entries.isEmpty)
                  const EmptyState(
                    message: 'لا يوجد متأخرون ولا مستحقون قريباً',
                    icon: Icons.check_circle_outline,
                  )
                else ...[
                  FilledButton.icon(
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text('إرسال تذكير للجميع (${state.entries.length})'),
                    onPressed: () => runAction(
                      context,
                      cubit.remindAll,
                      success: 'أُرسلت التذكيرات',
                      ms: 600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final e in state.entries)
                    SoftCard(
                      child: ListTile(
                        title: Text(e.title),
                        subtitle: Text('${e.borrowerName} · ${arabicDate(e.loan.dueAt)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusChip.forLoan(e.loan),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () => runAction(
                                context,
                                () => cubit.remind(e.loan.id),
                                success: 'أُرسل التذكير',
                                ms: 400,
                              ),
                              child: const Text('تذكير'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
