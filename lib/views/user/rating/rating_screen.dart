import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/user/rating/rating_cubit.dart';
import 'package:librarry_app/views/user/rating/rating_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/stars_view.dart';

/// قسم التقييمات في صفحة الكتاب: المتوسط، التقييم، التعليقات.
/// يقيّم المستخدم كتاباً استعاره (أو رقمياً قرأه/حمّله)، ويحذف الموظف أي تقييم.
class RatingSection extends StatelessWidget {
  const RatingSection({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RatingCubit(bookId),
      child: const _RatingView(),
    );
  }
}

class _RatingView extends StatefulWidget {
  const _RatingView();

  @override
  State<_RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<_RatingView> {
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comment.text = context.read<RatingCubit>().state.mine?.comment ?? '';
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cubit = context.read<RatingCubit>();
    if (cubit.state.stars == 0) {
      showMessage(context, 'اختر عدد النجوم');
      return;
    }
    await runAction(
      context,
      () => cubit.save(_comment.text),
      success: 'شكراً لتقييمك',
      ms: 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RatingCubit>();
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return BlocBuilder<RatingCubit, RatingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('التقييمات',
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (state.entries.isNotEmpty) ...[
                  StarsView(value: state.average),
                  const SizedBox(width: 6),
                  Text(
                    '${state.average.toStringAsFixed(1)} (${state.entries.length})',
                    style: muted,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (state.canRate) ...[
              Text(
                state.mine == null ? 'قيّم هذا الكتاب' : 'تقييمك الحالي، يمكنك تعديله',
                style: muted,
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: '$i من 5',
                      onPressed: () => cubit.selectStars(i),
                      icon: Icon(
                        i <= state.stars ? Icons.star : Icons.star_border,
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
                  child: Text(state.mine == null ? 'حفظ التقييم' : 'تحديث تقييمي'),
                ),
              ),
            ] else
              Text(
                state.isStaff
                    ? 'يمكنك حذف أي تقييم غير مناسب.'
                    : state.isDigital
                        ? 'يمكنك تقييم الكتاب بعد قراءته أو تحميله.'
                        : 'يمكنك تقييم الكتاب بعد استعارته.',
                style: muted,
              ),
            const SizedBox(height: 8),
            for (final e in state.entries)
              _RatingTile(entry: e, canDelete: state.isStaff),
          ],
        );
      },
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.entry, required this.canDelete});

  final RatingEntry entry;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final Rating rating = entry.rating;
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
                    Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                () => context.read<RatingCubit>().delete(rating.id),
                success: 'تم حذف التقييم',
                ms: 400,
              ),
            ),
        ],
      ),
    );
  }
}
