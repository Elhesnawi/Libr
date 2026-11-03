import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/staff/category_form/category_form_cubit.dart';
import 'package:librarry_app/views/staff/category_form/category_form_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

class CategoryFormScreen extends StatelessWidget {
  const CategoryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryFormCubit(),
      child: const _CategoryFormView(),
    );
  }
}

class _CategoryFormView extends StatefulWidget {
  const _CategoryFormView();

  @override
  State<_CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<_CategoryFormView> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<CategoryFormCubit>();
    final nav = Navigator.of(context);
    final ok = await runAction(
      context,
      () => cubit.save(_name.text),
      success: 'تمت إضافة القسم',
      ms: 600,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryFormCubit>();
    return Scaffold(
      appBar: const LibraryAppBar(title: 'إضافة قسم'),
      body: BlocBuilder<CategoryFormCubit, CategoryFormState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'اسم القسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('الأيقونة'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in categoryIcons.entries)
                  ChoiceChip(
                    label: Icon(entry.value, size: 22),
                    selected: state.iconKey == entry.key,
                    onSelected: (_) => cubit.selectIcon(entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('حفظ')),
          ],
        ),
      ),
    );
  }
}
