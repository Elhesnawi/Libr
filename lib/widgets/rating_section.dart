import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';

/// نجوم للعرض فقط (تُقرَّب القيمة لأقرب نجمة).
class StarsView extends StatelessWidget {
  const StarsView({super.key, required this.value, this.size = 14});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = value.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= filled ? Icons.star : Icons.star_border,
            size: size,
            color: Colors.amber.shade700,
          ),
      ],
    );
  }
}

/// قسم التقييمات في صفحة الكتاب: المتوسط، التقييم، التعليقات.
/// يقيّم المستخدم كتاباً استعاره (أو رقمياً قرأه/حمّله)، ويحذف الموظف أي تقييم.
class RatingSection extends StatefulWidget {
  const RatingSection({super.key, required this.bookId});

  final int bookId;

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  final _comment = TextEditingController();
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    final mine = LibraryStore.instance.myRating(widget.bookId);
    if (mine != null) {
      _stars = mine.stars;
      _comment.text = mine.comment;
    }
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_stars == 0) {
      showMessage(context, 'اختر عدد النجوم');
      return;
    }
    await runAction(
      context,
      () => LibraryStore.instance.rateBook(widget.bookId, _stars, comment: _comment.text),
      success: 'شكراً لتقييمك',
      ms: 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final book = store.bookById(widget.bookId);
    final ratings = store.ratingsOf(widget.bookId);
    final isStaff = store.currentUser?.role.isStaff ?? false;
    final canRate = store.canRate(widget.bookId);
    final mine = store.myRating(widget.bookId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('التقييمات', style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (ratings.isNotEmpty) ...[
              StarsView(value: store.averageRating(widget.bookId)),
              const SizedBox(width: 6),
              Text(
                '${store.averageRating(widget.bookId).toStringAsFixed(1)} (${ratings.length})',
                style: muted,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (canRate) ...[
          Text(mine == null ? 'قيّم هذا الكتاب' : 'تقييمك الحالي، يمكنك تعديله', style: muted),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: '$i من 5',
                  onPressed: () => setState(() => _stars = i),
                  icon: Icon(
                    i <= _stars ? Icons.star : Icons.star_border,
                    color: Colors.amber.shade700,
                    size: 30,
                  ),
                ),
            ],
          ),
          TextField(
            controller: _comment,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'أضف تعليقاً (اختياري)',
              border: OutlineInputBorder(),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonal(
              onPressed: _save,
              child: Text(mine == null ? 'حفظ التقييم' : 'تحديث تقييمي'),
            ),
          ),
        ] else
          Text(
            isStaff
                ? 'يمكنك حذف أي تقييم غير مناسب.'
                : (book?.isDigital ?? false)
                    ? 'يمكنك تقييم الكتاب بعد قراءته أو تحميله.'
                    : 'يمكنك تقييم الكتاب بعد استعارته.',
            style: muted,
          ),
        const SizedBox(height: 8),
        for (final r in ratings) _RatingTile(rating: r, canDelete: isStaff),
      ],
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.rating, required this.canDelete});

  final Rating rating;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final name = store.userByName(rating.username)?.fullName ?? rating.username;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    StarsView(value: rating.stars.toDouble(), size: 13),
                  ],
                ),
                if (rating.comment.isNotEmpty) Text(rating.comment),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              tooltip: 'حذف التقييم',
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error, size: 20),
              onPressed: () => runAction(
                context,
                () => store.deleteRating(rating.id),
                success: 'تم حذف التقييم',
                ms: 400,
              ),
            ),
        ],
      ),
    );
  }
}
