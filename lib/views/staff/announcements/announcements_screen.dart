import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/announcements/announcements_cubit.dart';
import 'package:librarry_app/views/staff/announcements/announcements_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/soft_card.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnnouncementsCubit(),
      child: const _AnnouncementsView(),
    );
  }
}

class _AnnouncementsView extends StatefulWidget {
  const _AnnouncementsView();

  @override
  State<_AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<_AnnouncementsView> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final cubit = context.read<AnnouncementsCubit>();
    final ok = await runAction(
      context,
      () => cubit.publish(_text.text),
      success: 'تم نشر الإعلان في الصفحة الرئيسية',
      ms: 600,
    );
    if (ok && mounted) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LibraryAppBar(title: 'الإعلانات'),
      body: BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _text,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'نص الإعلان',
                hintText: 'مثال: وصلت كتب جديدة في قسم القانون',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: _publish, child: const Text('نشر في الرئيسية')),
            const SectionTitle('الإعلانات الحالية'),
            if (state.announcements.isEmpty) const EmptyState(message: 'لا توجد إعلانات'),
            for (final a in state.announcements)
              SoftCard(
                child: ListTile(
                  title: Text(a.text),
                  subtitle: Text(arabicDate(a.date)),
                  trailing: IconButton(
                    tooltip: 'حذف',
                    icon: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () => runAction(
                      context,
                      () => context.read<AnnouncementsCubit>().delete(a.id),
                      success: 'تم حذف الإعلان',
                      ms: 400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
