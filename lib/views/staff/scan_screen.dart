import 'package:flutter/material.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// مسح الباركود للاستعارة والإرجاع السريع.
///
/// ملاحظة: القراءة هنا محاكاة بقوائم اختيار. عند إضافة حزمة الكاميرا
/// (مثل mobile_scanner) تُستبدل القائمتان بقراءة حقيقية للرمز BK-xxxx
/// ويبقى باقي المنطق كما هو.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _line;
  bool _borrow = true;
  String? _username;
  int? _bookId;

  @override
  void initState() {
    super.initState();
    _line = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    final store = LibraryStore.instance;
    final members = store.users.where((u) => u.role == UserRole.user).toList();
    _username = members.isEmpty ? null : members.first.username;
    _bookId = store.books.isEmpty ? null : store.books.first.id;
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final store = LibraryStore.instance;
    final username = _username;
    final bookId = _bookId;
    if (username == null || bookId == null) {
      showMessage(context, 'اختر المستعير والكتاب');
      return;
    }
    final borrow = _borrow;
    await runAction(
      context,
      () {
        if (borrow) {
          store.borrow(bookId, forUsername: username);
        } else {
          store.returnByScan(username, bookId);
        }
      },
      success: borrow ? 'تمت الاستعارة للمستعير' : 'تم تسجيل الإرجاع',
      ms: 900,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    final scheme = Theme.of(context).colorScheme;
    final members = store.users.where((u) => u.role == UserRole.user).toList();
    final books = store.books;

    return Scaffold(
      appBar: const LibraryAppBar(title: 'مسح الباركود'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF141413),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 44, color: Colors.white70),
                      SizedBox(height: 6),
                      Text(
                        'وجّه الكاميرا نحو باركود الكتاب',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _line,
                  builder: (context, _) => Align(
                    alignment: Alignment(0, -0.8 + 1.6 * _line.value),
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('استعارة'), icon: Icon(Icons.north_east)),
              ButtonSegment(value: false, label: Text('إرجاع'), icon: Icon(Icons.south_west)),
            ],
            selected: {_borrow},
            onSelectionChanged: (s) => setState(() => _borrow = s.first),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _username,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'المستعير (بطاقة العضوية)',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final u in members)
                DropdownMenuItem(value: u.username, child: Text('${u.fullName} · ${u.username}')),
            ],
            onChanged: (v) => setState(() => _username = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _bookId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'الكتاب الممسوح (محاكاة)',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final b in books)
                DropdownMenuItem(
                  value: b.id,
                  child: Text('${b.code} · ${b.title}', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _bookId = v),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _confirm, child: const Text('تأكيد العملية')),
          const SizedBox(height: 10),
          Text(
            'في النسخة النهائية تقرأ الكاميرا الباركود تلقائياً بدل القوائم.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
