import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// إضافة كتاب جديد، أو تعديل كتاب موجود عند تمرير [book].
/// الحقول: العنوان، المؤلف، تاريخ النشر، القسم، صورة الغلاف،
/// وللكتاب الرقمي ملف PDF، وللورقي عدد النسخ.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _copies;
  late int? _categoryId;
  late bool _digital;
  DateTime? _publishDate;
  Uint8List? _cover;
  String? _fileName;
  String? _error;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    final cats = LibraryStore.instance.categories;
    _title = TextEditingController(text: b?.title ?? '');
    _author = TextEditingController(text: b?.author ?? '');
    _copies = TextEditingController(text: '${b?.totalCopies ?? 1}');
    _categoryId = b?.categoryId ?? (cats.isEmpty ? null : cats.first.id);
    _digital = b?.isDigital ?? false;
    _publishDate = b?.publishDate;
    _cover = b?.coverBytes;
    _fileName = b?.fileName;
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _copies.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _publishDate = picked);
  }

  Future<void> _pickCover() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _cover = bytes);
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر اختيار الصورة');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final name = result?.files.single.name;
      if (name != null && mounted) setState(() => _fileName = name);
    } catch (_) {
      if (mounted) showMessage(context, 'تعذر اختيار الملف');
    }
  }

  Future<void> _save() async {
    final store = LibraryStore.instance;
    final nav = Navigator.of(context);
    final catId = _categoryId;
    if (catId == null) {
      setState(() => _error = 'أضف قسماً أولاً');
      return;
    }
    final copies = _digital ? 1 : (int.tryParse(_copies.text.trim()) ?? 0);
    final book = widget.book;
    setState(() => _error = null);
    final ok = await runAction(
      context,
      () {
        if (book == null) {
          store.addBook(
            title: _title.text,
            author: _author.text,
            categoryId: catId,
            isDigital: _digital,
            copies: copies,
            publishDate: _publishDate,
            coverBytes: _cover,
            fileName: _fileName,
          );
        } else {
          store.updateBook(
            book.id,
            title: _title.text,
            author: _author.text,
            categoryId: catId,
            isDigital: _digital,
            copies: copies,
            publishDate: _publishDate,
            coverBytes: _cover,
            fileName: _fileName,
          );
        }
      },
      success: book == null ? 'تمت إضافة الكتاب' : 'تم حفظ التعديل',
      ms: 800,
      onError: (message) => setState(() => _error = message),
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cats = LibraryStore.instance.categories;
    final scheme = Theme.of(context).colorScheme;
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
                _publishDate == null ? 'اختر التاريخ' : arabicDate(_publishDate!),
                style: _publishDate == null
                    ? TextStyle(color: scheme.onSurfaceVariant)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _categoryId,
            decoration: const InputDecoration(
              labelText: 'القسم',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final c in cats) DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('كتاب رقمي'),
            subtitle: const Text('يُقرأ ويُحمَّل مباشرة بلا استعارة'),
            value: _digital,
            onChanged: (v) => setState(() => _digital = v),
          ),
          if (_digital) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(_fileName ?? 'رفع ملف الكتاب (PDF)'),
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
              if (_cover != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(_cover!, width: 84, height: 112, fit: BoxFit.cover),
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
                  label: Text(_cover == null ? 'اختيار صورة' : 'تغيير الصورة'),
                  onPressed: _pickCover,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: scheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('حفظ الكتاب')),
        ],
      ),
    );
  }
}

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _name = TextEditingController();
  String _iconKey = 'folder';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nav = Navigator.of(context);
    final ok = await runAction(
      context,
      () => LibraryStore.instance.addCategory(_name.text, iconKey: _iconKey),
      success: 'تمت إضافة القسم',
      ms: 600,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LibraryAppBar(title: 'إضافة قسم'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'اسم القسم',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('الأيقونة'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in categoryIcons.entries)
                ChoiceChip(
                  label: Icon(entry.value, size: 22),
                  selected: _iconKey == entry.key,
                  onSelected: (_) => setState(() => _iconKey = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('حفظ')),
        ],
      ),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  UserRole _role = UserRole.user;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nav = Navigator.of(context);
    final ok = await runAction(
      context,
      () => LibraryStore.instance.addUser(
        username: _username.text,
        fullName: _name.text,
        role: _role,
      ),
      success: 'تم إنشاء الحساب. كلمة المرور المؤقتة: ${LibraryStore.tempPassword}',
      ms: 700,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LibraryAppBar(title: 'إنشاء حساب'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _username,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم (إنجليزي)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<UserRole>(
            initialValue: _role,
            decoration: const InputDecoration(
              labelText: 'الصلاحية',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final r in UserRole.values)
                DropdownMenuItem(value: r, child: Text(r.label)),
            ],
            onChanged: (v) => setState(() => _role = v ?? UserRole.user),
          ),
          const SizedBox(height: 8),
          Text(
            'تُعطى كلمة مرور مؤقتة (${LibraryStore.tempPassword}) ويغيّرها المستخدم بعد أول دخول.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('إنشاء')),
        ],
      ),
    );
  }
}
