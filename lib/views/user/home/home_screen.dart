import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/book_request/book_request_screen.dart';
import 'package:librarry_app/views/user/category_books/category_books_screen.dart';
import 'package:librarry_app/views/user/history/history_screen.dart';
import 'package:librarry_app/views/user/home/home_cubit.dart';
import 'package:librarry_app/views/user/home/home_state.dart';
import 'package:librarry_app/views/user/shell/shell_navigation.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_type_selector.dart';
import 'package:librarry_app/widgets/welcome_card.dart';

/// الشاشة الرئيسية: الترحيب، الوصول السريع، الأقسام، واقتراحات المكتبة الذكية.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) return const SizedBox.shrink();
        final announcement = state.announcement;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WelcomeCard(
          fullName: user.fullName,
          role: user.role,
          lastLogin: state.previousLogin,
          borrowedCount: state.loans.length,
          maxLoans: LibraryStore.maxLoans,
          favoritesCount: state.favoritesCount,
          nextLoan: state.nextLoan,
          nextLoanTitle: state.nextTitle,
          onBorrowedTap: () => switchTab(context, 2),
          onFavoritesTap: () => switchTab(context, 3),
        ),
        if (announcement != null) ...[
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
                        'إعلان من المكتبة · ${arabicDate(announcement.date)}',
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      Text(announcement.text),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SectionTitle('الوصول السريع'),
        TextField(
          onChanged: context.read<HomeCubit>().setQuery,
          decoration: const InputDecoration(
            hintText: 'ابحث بعنوان الكتاب أو المؤلف',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        if (state.query.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          BookList(books: state.results),
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
          selected: state.type,
          onChanged: context.read<HomeCubit>().setType,
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
            for (final c in state.categories)
              _CategoryTile(
                category: c,
                count: state.counts[c.id] ?? 0,
                onTap: () => openScreen(
                  context,
                  CategoryBooksScreen(category: c, type: state.type),
                ),
              ),
          ],
        ),
        if (state.suggestions.isNotEmpty) ...[
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
                      state.hasActivity ? 'المكتبة الذكية تقترح عليك' : 'الأكثر استعارة في المكتبة',
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
                for (final b in state.suggestions) BookTile(book: b),
              ],
            ),
          ),
        ],
      ],
    );
      },
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
