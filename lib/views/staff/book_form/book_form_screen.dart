import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/views/staff/book_form/book_form_cubit.dart';
import 'package:librarry_app/views/staff/book_form/book_form_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// إضافة كتاب جديد، أو تعديل كتاب موجود عند تمرير [book].
/// الحقول: العنوان، المؤلف، تاريخ النشر، القسم، صورة الغلاف،
/// وللكتاب الرقمي ملف PDF، وللورقي عدد النسخ.
class BookFormScreen extends StatelessWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookFormCubit(book),
      child: _BookFormView(book: book),
    );
  }
}

class _BookFormView extends StatefulWidget {
  const _BookFormView({required this.book});

  final Book? book;

  @override
  State<_BookFormView> createState() => _BookFormViewState();
}

class _BookFormViewState extends State<_BookFormView> {
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _copies;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _title = TextEditingController(text: b?.title ?? '');
    _author = TextEditingController(text: b?.author ?? '');
    _copies = TextEditingController(text: '${b?.totalCopies ?? 1}');
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _copies.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final cubit = context.read<BookFormCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.publishDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) cubit.setPublishDate(picked);
  }

  Future<void> _pickCover() async {
    final cubit = context.read<BookFormCubit>();
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 85,
      );
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      if (!cubit.isClosed) cubit.setCover(bytes);
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر اختيار الصورة');
    }
  }

  Future<void> _pickPdf() async {
    final cubit = context.read<BookFormCubit>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final name = result?.files.single.name;
      if (name != null && !cubit.isClosed) cubit.setFileName(name);
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر اختيار الملف');
    }
  }

  Future<void> _save() async {
    final cubit = context.read<BookFormCubit>();
    final nav = Navigator.of(context);
    cubit.clearError();
    final ok = await runAction(
      context,
      () => cubit.save(
        title: _title.text,
        author: _author.text,
        copiesText: _copies.text,
      ),
      success: widget.book == null ? 'تمت إضافة الكتاب' : 'تم حفظ التعديل',
      ms: 800,
      onError: cubit.showError,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookFormCubit>();
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<BookFormCubit, BookFormState>(
      builder: (context, state) {
    return Scaffold(
      appBar: LibraryAppBar(title: widget.book == null ? 'إضافة كتاب' : 'تعديل كتاب'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
              labelText: 'المؤلف',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'تاريخ النشر',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                state.publishDate == null ? 'اختر التاريخ' : arabicDate(state.publishDate!),
                style: state.publishDate == null
                    ? TextStyle(color: scheme.onSurfaceVariant)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: state.categoryId,
            decoration: const InputDecoration(
              labelText: 'القسم',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final c in state.categories) DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: cubit.setCategory,
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('كتاب رقمي'),
            subtitle: const Text('يُقرأ ويُحمَّل مباشرة بلا استعارة'),
            value: state.digital,
            onChanged: cubit.setDigital,
          ),
          if (state.digital) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(state.fileName ?? 'رفع ملف الكتاب (PDF)'),
              onPressed: _pickPdf,
            ),
          ] else
            TextField(
              controller: _copies,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'عدد النسخ',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          const Text('صورة الغلاف'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.cover != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(state.cover!, width: 84, height: 112, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 84,
                  height: 112,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'لا توجد صورة',
                    style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.image_outlined),
                  label: Text(state.cover == null ? 'اختيار صورة' : 'تغيير الصورة'),
                  onPressed: _pickCover,
                ),
              ),
            ],
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(state.error!, style: TextStyle(color: scheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('حفظ الكتاب')),
        ],
      ),
    );
      },
    );
  }
}
