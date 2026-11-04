import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/staff/scan/scan_cubit.dart';
import 'package:librarry_app/views/staff/scan/scan_state.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// مسح الباركود للاستعارة والإرجاع السريع.
///
/// ملاحظة: القراءة هنا محاكاة بقوائم اختيار. عند إضافة حزمة الكاميرا
/// (مثل mobile_scanner) تُستبدل القائمتان بقراءة حقيقية للرمز BK-xxxx
/// ويبقى باقي المنطق كما هو.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCubit(),
      child: const _ScanView(),
    );
  }
}

class _ScanView extends StatefulWidget {
  const _ScanView();

  @override
  State<_ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<_ScanView> with SingleTickerProviderStateMixin {
  // حركة خط المسح: حالة عرض فقط، لذلك تبقى في الواجهة.
  late final AnimationController _line;

  @override
  void initState() {
    super.initState();
    _line = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final cubit = context.read<ScanCubit>();
    final borrow = cubit.state.borrow;
    await runAction(
      context,
      cubit.confirm,
      success: borrow ? 'تمت الاستعارة للمستعير' : 'تم تسجيل الإرجاع',
      ms: 900,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<ScanCubit>();
    return Scaffold(
      appBar: const LibraryAppBar(title: 'مسح الباركود'),
      body: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) => ListView(
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
            selected: {state.borrow},
            onSelectionChanged: (s) => cubit.setBorrow(s.first),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: state.username,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'المستعير (بطاقة العضوية)',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final u in state.members)
                DropdownMenuItem(value: u.username, child: Text('${u.fullName} · ${u.username}')),
            ],
            onChanged: cubit.setUsername,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: state.bookId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'الكتاب الممسوح (محاكاة)',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final b in state.books)
                DropdownMenuItem(
                  value: b.id,
                  child: Text('${b.code} · ${b.title}', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: cubit.setBook,
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
      ),
    );
  }
}
