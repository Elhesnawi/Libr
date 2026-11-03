import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/views/user/search/search_cubit.dart';
import 'package:librarry_app/views/user/search/search_state.dart';
import 'package:librarry_app/widgets/book_tile.dart';

/// البحث الذكي: يتجاهل التشكيل والفروق بين الهمزات، مع تصفية بالقسم والنوع.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final hint = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: cubit.setQuery,
            decoration: const InputDecoration(
              hintText: 'ابحث بعنوان الكتاب أو المؤلف',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
            child: Text('البحث الذكي يتجاهل التشكيل والفروق بين الهمزات. جرّب "الاداري".', style: hint),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('كل الأقسام'),
                selected: state.categoryId == null,
                onSelected: (_) => cubit.setCategory(null),
              ),
              for (final c in state.categories)
                ChoiceChip(
                  label: Text(c.name),
                  selected: state.categoryId == c.id,
                  onSelected: (_) => cubit.setCategory(c.id),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: state.type == null,
                onSelected: (_) => cubit.setType(null),
              ),
              ChoiceChip(
                label: const Text('ورقي'),
                selected: state.type == LibraryType.paper,
                onSelected: (_) => cubit.setType(LibraryType.paper),
              ),
              ChoiceChip(
                label: const Text('رقمي'),
                selected: state.type == LibraryType.digital,
                onSelected: (_) => cubit.setType(LibraryType.digital),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BookList(books: state.results),
        ],
      ),
    );
  }
}
