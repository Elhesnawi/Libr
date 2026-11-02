import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/book_request_screen.dart';
import 'package:librarry_app/views/user/category_books_screen.dart';
import 'package:librarry_app/views/user/history_screen.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_type_selector.dart';
import 'package:librarry_app/widgets/welcome_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.user, required this.onSwitchTab});

  final AppUser user;
  final Future<void> Function(int index) onSwitchTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  LibraryType _type = LibraryType.paper;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final user = widget.user;

    final loans = store.activeLoansOf(user.username);
    final next = loans.isEmpty ? null : loans.first;
    final nextTitle = next == null ? null : store.bookById(next.bookId)?.title;
    final announcements = store.announcements;
    final results = _query.trim().isEmpty
        ? <Book>[]
        : store.search(query: _query).take(5).toList();
    final hasActivity = store.hasActivity(user.username);
    final suggestions = store.suggestionsFor(user.username);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WelcomeCard(
          fullName: user.fullName,
          role: user.role,
          lastLogin: store.previousLogin,
          borrowedCount: loans.length,
          maxLoans: LibraryStore.maxLoans,
          favoritesCount: store.favoritesCount,
          nextLoan: next,
          nextLoanTitle: nextTitle,
          onBorrowedTap: () => widget.onSwitchTab(2),
          onFavoritesTap: () => widget.onSwitchTab(3),
        ),
        if (announcements.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.campaign_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعلان من المكتبة · ${arabicDate(announcements.first.date)}',
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      Text(announcements.first.text),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SectionTitle('الوصول السريع'),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'ابحث بعنوان الكتاب أو المؤلف',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (_query.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          BookList(books: results),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Shortcut(
                icon: Icons.history,
                label: 'سجل الاستعارات',
                onTap: () => openScreen(context, const HistoryScreen()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Shortcut(
                icon: Icons.lightbulb_outline,
                label: 'اقتراح كتاب',
                onTap: () => openScreen(context, const BookRequestScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LibraryTypeSelector(
          selected: _type,
          onChanged: (t) => setState(() => _type = t),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            for (final c in store.categories)
              _CategoryTile(
                category: c,
                count: store.countIn(c.id, _type),
                onTap: () => openScreen(
                  context,
                  CategoryBooksScreen(category: c, type: _type),
                ),
              ),
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      hasActivity ? 'المكتبة الذكية تقترح عليك' : 'الأكثر استعارة في المكتبة',
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 10),
                  child: Text(
                    hasActivity
                        ? 'بناءً على أقسامك المفضلة وآخر استعاراتك'
                        : 'ابدأ من الكتب التي يقرؤها زملاؤك',
                    style: text.bodySmall,
                  ),
                ),
                for (final b in suggestions) BookTile(book: b),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.count, required this.onTap});

  final BookCategory category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 30, color: scheme.primary),
            const SizedBox(height: 6),
            Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$count كتب', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
