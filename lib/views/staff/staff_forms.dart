import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// إضافة كتاب جديد، أو تعديل كتاب موجود عند تمرير [book].
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
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _copies.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = LibraryStore.instance;
    final nav = Navigator.of(context);
    final catId = _categoryId;
    if (catId == null) {
      showMessage(context, 'أضف قسماً أولاً');
      return;
    }
    final copies = int.tryParse(_copies.text.trim()) ?? 0;
    final book = widget.book;
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
          );
        } else {
          store.updateBook(
            book.id,
            title: _title.text,
            author: _author.text,
            categoryId: catId,
            isDigital: _digital,
            copies: copies,
          );
        }
      },
      success: 'تم الحفظ',
      ms: 800,
    );
    if (ok && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cats = LibraryStore.instance.categories;
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
          const SizedBox(height: 12),
          TextField(
            controller: _copies,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'عدد النسخ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('كتاب رقمي'),
            subtitle: const Text('رفع ملف PDF والغلاف يتم بعد ربط الخادم'),
            value: _digital,
            onChanged: (v) => setState(() => _digital = v),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('حفظ')),
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
