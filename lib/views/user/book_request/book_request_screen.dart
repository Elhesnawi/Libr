import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/views/user/book_request/book_request_cubit.dart';
import 'package:librarry_app/views/user/book_request/book_request_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

/// اقتراح كتاب غير موجود: يصل الطلب إلى أمين المكتبة ليقبله أو يرفضه.
class BookRequestScreen extends StatelessWidget {
  const BookRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookRequestCubit(),
      child: const _BookRequestView(),
    );
  }
}

class _BookRequestView extends StatefulWidget {
  const _BookRequestView();

  @override
  State<_BookRequestView> createState() => _BookRequestViewState();
}

class _BookRequestViewState extends State<_BookRequestView> {
  final _title = TextEditingController();
  final _author = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final cubit = context.read<BookRequestCubit>();
    final ok = await runAction(
      context,
      () => cubit.submit(_title.text, _author.text),
      success: 'تم إرسال طلبك إلى أمين المكتبة',
      ms: 800,
    );
    if (ok && mounted) {
      _title.clear();
      _author.clear();
    }
  }

  static Tone _tone(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return Tone.warning;
      case RequestStatus.accepted:
        return Tone.success;
      case RequestStatus.rejected:
        return Tone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LibraryAppBar(title: 'اقتراح كتاب'),
      body: BlocBuilder<BookRequestCubit, BookRequestState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'لم تجد كتاباً تحتاجه؟ اقترحه وسيراجعه أمين المكتبة.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'عنوان الكتاب',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _author,
              decoration: const InputDecoration(
                labelText: 'المؤلف (اختياري)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: _send, child: const Text('إرسال الطلب')),
            if (state.requests.isNotEmpty) ...[
              const SectionTitle('طلباتي'),
              for (final r in state.requests)
                SoftCard(
                  child: ListTile(
                    title: Text(r.title),
                    subtitle: Text(r.author),
                    trailing: StatusChip(label: r.status.label, tone: _tone(r.status)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
