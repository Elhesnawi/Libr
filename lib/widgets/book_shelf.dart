import 'package:flutter/material.dart';
import 'package:librarry_app/models/category_shelf.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/user/book_popup/book_popup_screen.dart';
import 'package:librarry_app/widgets/book_cover.dart';

/// صف أغلفة أفقي قابل للتمرير يميناً ويساراً. الضغط على الغلاف يفتح الكتاب.
class BookShelf extends StatelessWidget {
  const BookShelf({super.key, required this.books});

  final List<Book> books;

  static const double itemWidth = 104;
  static const double coverHeight = 138;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: coverHeight + 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _ShelfItem(book: books[i]),
      ),
    );
  }
}

class _ShelfItem extends StatelessWidget {
  const _ShelfItem({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: BookShelf.itemWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => openBook(context, book.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              book: book,
              width: BookShelf.itemWidth,
              height: BookShelf.coverHeight,
              iconSize: 36,
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// قسم رئيسي (الكتب الرقمية / المكتبة الورقية): عنوان، شريط أقسام أفقي،
/// وتحته صف كتب القسم المختار. الضغط على قسم يغيّر الكتب المعروضة.
class CategoryShelfSection extends StatelessWidget {
  const CategoryShelfSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.data,
    required this.onSelect,
    required this.onSeeAll,
    this.tint,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final LibrarySectionData data;
  final ValueChanged<int> onSelect;
  final ValueChanged<BookCategory> onSeeAll;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final current = data.selected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: tint ?? scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (current == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text('لا توجد كتب بعد', style: text.bodyMedium),
              ),
            )
          else ...[
            _CategoryTabs(
              shelves: data.shelves,
              selectedId: current.category.id,
              onSelect: onSelect,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${current.books.length} كتاب',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => onSeeAll(current.category),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('عرض الكل'),
                      Icon(Icons.chevron_left, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            BookShelf(
              // مفتاح مختلف لكل قسم ليبدأ الصف من أوله عند تغيير القسم.
              key: ValueKey('${data.type.name}-${current.category.id}'),
              books: current.books,
            ),
          ],
        ],
      ),
    );
  }
}

/// شريط أقسام أفقي قابل للتمرير، والمختار تحته خط بلون التطبيق.
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.shelves,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CategoryShelf> shelves;
  final int selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final s in shelves)
              _Tab(
                label: s.category.name,
                selected: s.category.id == selectedId,
                onTap: () => onSelect(s.category.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Semantics(
        selected: selected,
        button: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? scheme.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
