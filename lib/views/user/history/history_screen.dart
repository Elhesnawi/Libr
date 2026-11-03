import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/history/history_cubit.dart';
import 'package:librarry_app/views/user/history/history_state.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// سجل الاستعارات السابقة (التي أُعيدت).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'سجل الاستعارات'),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state.entries.isEmpty) {
              return const EmptyState(
                message: 'لا توجد استعارات سابقة',
                icon: Icons.history,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final e in state.entries)
                  if (e.book != null)
                    BookTile(
                      book: e.book!,
                      trailing: Text(
                        e.loan.returnedAt == null
                            ? ''
                            : 'أُعيد ${arabicDate(e.loan.returnedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall,
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
