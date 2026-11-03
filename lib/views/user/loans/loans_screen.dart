import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/user/loans/loans_cubit.dart';
import 'package:librarry_app/views/user/loans/loans_state.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';

/// استعاراتي الحالية مع موعد الإرجاع.
class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoansCubit(),
      child: BlocBuilder<LoansCubit, LoansState>(
        builder: (context, state) {
          if (state.entries.isEmpty) {
            return const EmptyState(
              message: 'لا توجد استعارات حالية',
              icon: Icons.menu_book_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final e in state.entries)
                if (e.book != null)
                  BookTile(book: e.book!, trailing: StatusChip.forLoan(e.loan)),
            ],
          );
        },
      ),
    );
  }
}
