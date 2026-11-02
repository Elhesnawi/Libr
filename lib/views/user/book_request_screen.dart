import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// اقتراح كتاب غير موجود: يصل الطلب إلى أمين المكتبة ليقبله أو يرفضه.
class BookRequestScreen extends StatefulWidget {
  const BookRequestScreen({super.key});

  @override
  State<BookRequestScreen> createState() => _BookRequestScreenState();
}

class _BookRequestScreenState extends State<BookRequestScreen> {
  final _title = TextEditingController();
  final _author = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await runAction(
      context,
      () => LibraryStore.instance.submitRequest(
        title: _title.text,
        author: _author.text,
      ),
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
    final store = LibraryStore.instance;
    return Scaffold(
      appBar: const LibraryAppBar(title: 'اقتراح كتاب'),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final user = store.currentUser;
          if (user == null) return const SizedBox.shrink();
          final mine = store.requestsOf(user.username);
          return ListView(
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
              if (mine.isNotEmpty) ...[
                const SectionTitle('طلباتي'),
                for (final r in mine)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    child: ListTile(
                      title: Text(r.title),
                      subtitle: Text(r.author),
                      trailing: StatusChip(label: r.status.label, tone: _tone(r.status)),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
