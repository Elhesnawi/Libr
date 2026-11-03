import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/staff/categories/categories_cubit.dart';
import 'package:librarry_app/views/staff/categories/categories_state.dart';
import 'package:librarry_app/views/staff/category_form/category_form_screen.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit(),
      child: Scaffold(
        appBar: const LibraryAppBar(title: 'الأقسام'),
        body: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة قسم'),
                onPressed: () => openScreen(context, const CategoryFormScreen()),
              ),
              const SizedBox(height: 12),
              for (final row in state.rows)
                SoftCard(
                  child: ListTile(
                    leading: Icon(row.category.icon),
                    title: Text(row.category.name),
                    subtitle: Text('${row.bookCount} كتب'),
                    trailing: state.isAdmin
                        ? IconButton(
                            tooltip: 'حذف',
                            icon: Icon(Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () async {
                              final cubit = context.read<CategoriesCubit>();
                              final yes = await confirmDialog(
                                context,
                                title: 'حذف القسم',
                                message: 'هل تريد حذف قسم "${row.category.name}"؟',
                                confirmLabel: 'حذف',
                              );
                              if (!yes || !context.mounted) return;
                              await runAction(
                                context,
                                () => cubit.delete(row.category.id),
                                success: 'تم حذف القسم',
                                ms: 600,
                              );
                            },
                          )
                        : null,
                  ),
                ),
              if (!state.isAdmin)
                Text('حذف الأقسام للمدير فقط', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
