import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/book_request/book_request_screen.dart';
import 'package:librarry_app/views/user/category_books/category_books_screen.dart';
import 'package:librarry_app/views/user/history/history_screen.dart';
import 'package:librarry_app/views/user/home/home_cubit.dart';
import 'package:librarry_app/views/user/home/home_state.dart';
import 'package:librarry_app/views/user/shell/shell_navigation.dart';
import 'package:librarry_app/widgets/book_shelf.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';
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
        final cubit = context.read<HomeCubit>();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WelcomeCard(
              fullName: user.fullName,
              role: user.role,
              nextLoan: state.nextLoan,
              nextLoanTitle: state.nextTitle,
              onNextLoanTap: () => switchTab(context, 2),
              onHistoryTap: () => openScreen(context, const HistoryScreen()),
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
              onChanged: cubit.setQuery,
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
            _Shortcut(
              icon: Icons.lightbulb_outline,
              label: 'اقتراح كتاب',
              onTap: () => openScreen(context, const BookRequestScreen()),
            ),
            const SizedBox(height: 16),
            CategoryShelfSection(
              title: 'الكتب الرقمية',
              subtitle: 'قراءة وتحميل',
              icon: Icons.tablet_android,
              tint: scheme.primaryContainer.withValues(alpha: 0.5),
              data: state.digital,
              onSelect: (id) => cubit.selectCategory(LibraryType.digital, id),
              onSeeAll: (c) => openScreen(
                context,
                CategoryBooksScreen(category: c, type: LibraryType.digital),
              ),
            ),
            const SizedBox(height: 14),
            CategoryShelfSection(
              title: 'المكتبة',
              subtitle: 'الكتب الورقية',
              icon: Icons.local_library_outlined,
              data: state.paper,
              onSelect: (id) => cubit.selectCategory(LibraryType.paper, id),
              onSeeAll: (c) => openScreen(
                context,
                CategoryBooksScreen(category: c, type: LibraryType.paper),
              ),
            ),
            if (state.suggestions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
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
                        state.hasActivity
                            ? 'بناءً على أقسامك المفضلة وآخر استعاراتك'
                            : 'ابدأ من الكتب التي يقرؤها زملاؤك',
                        style: text.bodySmall,
                      ),
                    ),
                    BookShelf(books: state.suggestions),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
