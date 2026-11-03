import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/user/book_details_screen.dart';
import 'package:librarry_app/views/user/reader_screen.dart';
import 'package:librarry_app/widgets/book_cover.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/rating_section.dart';

enum _PopupAction { borrow, reserve, read, download, details }

/// يفتح الكتاب بحسب نوع المستخدم:
/// - المستخدم العادي: نافذة منبثقة بخيارات سريعة.
///   ورقي: استعارة (أو حجز) / إلغاء. رقمي: قراءة / تحميل / إلغاء.
/// - الموظف والمدير: صفحة تفاصيل الكتاب كاملة.
Future<void> openBook(BuildContext context, int bookId) async {
  final store = LibraryStore.instance;
  final user = store.currentUser;
  if (user == null) return;
  if (user.role.isStaff) {
    await openScreen(context, BookDetailsScreen(bookId: bookId));
    return;
  }
  final book = store.bookById(bookId);
  if (book == null) return;

  final action = await showDialog<_PopupAction>(
    context: context,
    builder: (_) => _BookPopup(book: book),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _PopupAction.borrow:
      await runAction(
        context,
        () => store.borrow(bookId),
        success: 'تمت الاستعارة. موعد الإرجاع بعد ${LibraryStore.loanDays} يوماً',
        ms: 800,
      );
      break;
    case _PopupAction.reserve:
      await runAction(
        context,
        () => store.reserve(bookId),
        success: 'تم الحجز. سنخطرك عند توفر الكتاب',
      );
      break;
    case _PopupAction.read:
      await openScreen(context, ReaderScreen(bookId: bookId));
      break;
    case _PopupAction.download:
      await runAction(
        context,
        () => store.downloadBook(bookId),
        success: 'تم التحميل (محاكاة). في التطبيق الحقيقي يُحفظ الملف على جهازك',
        ms: 800,
      );
      break;
    case _PopupAction.details:
      await openScreen(context, BookDetailsScreen(bookId: bookId));
      break;
  }
}

class _BookPopup extends StatelessWidget {
  const _BookPopup({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final category = store.categoryById(book.categoryId);
    final mine = store.activeLoansOf(store.currentUser?.username ?? '')
        .where((l) => l.bookId == book.id)
        .toList();
    final reserved = store.hasReserved(book.id);
    final count = store.ratingCount(book.id);
    final started = store.readingPage(book.id) > 0;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(book: book, width: 78, height: 104, iconSize: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(book.author, style: muted),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            StatusChip(label: category?.name ?? '', tone: Tone.info),
                            StatusChip(
                              label: book.isDigital ? 'رقمي' : 'ورقي',
                              tone: Tone.warning,
                            ),
                            if (!book.isDigital)
                              StatusChip(
                                label: book.isAvailable ? 'متاح' : 'غير متاح',
                                tone: book.isAvailable ? Tone.success : Tone.danger,
                              ),
                          ],
                        ),
                        if (count > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              StarsView(value: store.averageRating(book.id)),
                              const SizedBox(width: 6),
                              Text(
                                '${store.averageRating(book.id).toStringAsFixed(1)} ($count)',
                                style: muted,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoRow(
                label: 'تاريخ النشر',
                value: book.publishDate == null ? '—' : arabicDate(book.publishDate!),
              ),
              if (book.isDigital)
                const _InfoRow(label: 'الصيغة', value: 'PDF')
              else
                _InfoRow(
                  label: 'النسخ المتاحة',
                  value: '${book.availableCopies} / ${book.totalCopies}',
                ),
              _InfoRow(label: 'رمز الكتاب', value: book.code),
              if (mine.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: StatusChip(
                    label: 'لديك هذا الكتاب. ${dueText(mine.first.daysLeft)}',
                    tone: mine.first.isOverdue ? Tone.danger : Tone.success,
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(_PopupAction.details),
                  child: const Text('التقييمات'),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        if (book.isDigital) ...[
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_PopupAction.read),
            child: Text(started ? 'تابع القراءة' : 'قراءة'),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('تحميل'),
            onPressed: () => Navigator.of(context).pop(_PopupAction.download),
          ),
        ] else if (book.isAvailable)
          FilledButton(
            onPressed: mine.isNotEmpty
                ? null
                : () => Navigator.of(context).pop(_PopupAction.borrow),
            child: const Text('استعارة'),
          )
        else
          FilledButton(
            onPressed: reserved
                ? null
                : () => Navigator.of(context).pop(_PopupAction.reserve),
            child: Text(reserved ? 'تم الحجز' : 'حجز'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
