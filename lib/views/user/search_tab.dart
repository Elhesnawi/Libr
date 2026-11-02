import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/book_tile.dart';

/// البحث الذكي: يتجاهل التشكيل والفروق بين الهمزات، مع تصفية بالقسم والنوع.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _query = '';
  int? _categoryId;
  LibraryType? _type;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final hint = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => _list(store, hint),
    );
  }

  Widget _list(LibraryStore store, TextStyle? hint) {
    final results = store.search(
      query: _query,
      categoryId: _categoryId,
      type: _type,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
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
              selected: _categoryId == null,
              onSelected: (_) => setState(() => _categoryId = null),
            ),
            for (final c in store.categories)
              ChoiceChip(
                label: Text(c.name),
                selected: _categoryId == c.id,
                onSelected: (_) => setState(() => _categoryId = c.id),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('الكل'),
              selected: _type == null,
              onSelected: (_) => setState(() => _type = null),
            ),
            ChoiceChip(
              label: const Text('ورقي'),
              selected: _type == LibraryType.paper,
              onSelected: (_) => setState(() => _type = LibraryType.paper),
            ),
            ChoiceChip(
              label: const Text('رقمي'),
              selected: _type == LibraryType.digital,
              onSelected: (_) => setState(() => _type = LibraryType.digital),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BookList(books: results),
      ],
    );
  }
}
