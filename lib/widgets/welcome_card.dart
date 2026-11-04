import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/widgets/common.dart';

/// بطاقة الترحيب في الشاشة الرئيسية:
/// تحية حسب الوقت، الاسم، الصورة، نوع الحساب (للموظفين)، التاريخ، آخر دخول،
/// عدد الكتب المستعارة والمفضلة، وموعد الإرجاع القادم.
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    required this.fullName,
    required this.role,
    required this.lastLogin,
    required this.borrowedCount,
    required this.maxLoans,
    required this.favoritesCount,
    required this.nextLoan,
    required this.nextLoanTitle,
    this.onBorrowedTap,
    this.onFavoritesTap,
  });

  final String fullName;
  final UserRole role;
  final DateTime? lastLogin;
  final int borrowedCount;
  final int maxLoans;
  final int favoritesCount;
  final Loan? nextLoan;
  final String? nextLoanTitle;
  final VoidCallback? onBorrowedTap;
  final VoidCallback? onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.surface,
                child: Icon(Icons.person_outline, size: 30, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${greetingFor(now)}، $fullName 👋',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'أهلاً بعودتك إلى المكتبة الذكية',
                      style: text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (role.isStaff) ...[
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(
                role == UserRole.admin ? Icons.shield_outlined : Icons.local_library_outlined,
                size: 18,
              ),
              label: Text(role.label),
              visualDensity: VisualDensity.compact,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  label: 'اليوم',
                  value: arabicDate(now),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Tile(
                  label: 'آخر دخول',
                  value: lastLogin == null ? 'أول دخول' : arabicDayAndTime(lastLogin!),
                  icon: Icons.login,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  label: 'الكتب المستعارة',
                  value: '$borrowedCount من $maxLoans',
                  icon: Icons.menu_book_outlined,
                  big: true,
                  onTap: onBorrowedTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Tile(
                  label: 'الكتب المفضلة',
                  value: '$favoritesCount',
                  icon: Icons.bookmark_border,
                  big: true,
                  onTap: onFavoritesTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBorrowedTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.event_available_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('موعد الإرجاع القادم',
                              style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            nextLoanTitle ?? 'لا يوجد كتاب مستحق',
                            style: text.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    nextLoan == null
                        ? const StatusChip(label: 'لا توجد مستحقات', tone: Tone.success)
                        : StatusChip.forLoan(nextLoan!),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.icon,
    this.big = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool big;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.bodySmall, overflow: TextOverflow.ellipsis),
                    Text(
                      value,
                      style: (big ? text.titleMedium : text.bodyMedium)
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_left, size: 18, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
