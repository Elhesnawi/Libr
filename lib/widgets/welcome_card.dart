import 'package:flutter/material.dart';
import 'package:librarry_app/core/brand.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/utils/arabic_text.dart';

/// بطاقة الترحيب الداكنة في الشاشة الرئيسية:
/// الصورة والتحية والاسم، موعد الإرجاع القادم، وزر سجل الاستعارات.
/// (الكتب المستعارة والمفضلة انتقلت إلى شاشة «حسابي».)
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    required this.fullName,
    required this.role,
    required this.nextLoan,
    required this.nextLoanTitle,
    this.onNextLoanTap,
    this.onHistoryTap,
  });

  final String fullName;
  final UserRole role;
  final Loan? nextLoan;
  final String? nextLoanTitle;
  final VoidCallback? onNextLoanTap;
  final VoidCallback? onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: Brand.darkCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Brand.navyDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Brand.glass(0.16),
                child: const Icon(Icons.person_outline, size: 30, color: Colors.white),
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'أهلاً بعودتك إلى المكتبة الذكية',
                      style: text.bodyMedium?.copyWith(color: Brand.glass(0.75)),
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
                color: Brand.onGold,
              ),
              label: Text(role.label, style: const TextStyle(color: Brand.onGold)),
              backgroundColor: Brand.goldLight,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          ],
          const SizedBox(height: 14),
          _NextLoanStrip(
            loan: nextLoan,
            title: nextLoanTitle,
            onTap: onNextLoanTap,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onHistoryTap,
            icon: const Icon(Icons.history, size: 20),
            label: const Text('سجل الاستعارات'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              side: BorderSide(color: Brand.glass(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط موعد الإرجاع القادم داخل البطاقة الداكنة (يتلوّن حسب الحالة).
class _NextLoanStrip extends StatelessWidget {
  const _NextLoanStrip({required this.loan, required this.title, this.onTap});

  final Loan? loan;
  final String? title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final loan = this.loan;
    final Color chipBg;
    final Color chipFg;
    final String chipLabel;
    if (loan == null) {
      chipBg = Brand.okOnDark;
      chipFg = const Color(0xFF06301B);
      chipLabel = 'لا توجد مستحقات';
    } else {
      final d = loan.daysLeft;
      chipLabel = dueText(d);
      if (d < 0) {
        chipBg = Brand.badOnDark;
        chipFg = const Color(0xFF4A0A0A);
      } else if (d <= 3) {
        chipBg = Brand.warnOnDark;
        chipFg = const Color(0xFF4A3300);
      } else {
        chipBg = Brand.okOnDark;
        chipFg = const Color(0xFF06301B);
      }
    }

    return Material(
      color: Brand.glass(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Brand.glass(0.14)),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available_outlined, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موعد الإرجاع القادم',
                      style: text.bodySmall?.copyWith(color: Brand.glass(0.75)),
                    ),
                    Text(
                      title ?? 'لا يوجد كتاب مستحق',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: chipFg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
