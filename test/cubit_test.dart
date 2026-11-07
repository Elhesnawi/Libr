import 'package:flutter_test/flutter_test.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/credential_store.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/common/change_password/change_password_cubit.dart';
import 'package:librarry_app/views/login/login_cubit.dart';
import 'package:librarry_app/views/staff/book_form/book_form_cubit.dart';
import 'package:librarry_app/views/user/home/home_cubit.dart';
import 'package:librarry_app/views/user/loans/loans_cubit.dart';
import 'package:librarry_app/views/user/search/search_cubit.dart';

/// اختبارات الـ Cubits: تستعمل المخزن المشترك لأن الـ Cubits تقرأ منه مباشرة.
void main() {
  final store = LibraryStore.instance;

  setUp(() {
    if (store.currentUser != null) store.logout();
  });

  tearDown(() {
    if (store.currentUser != null) store.logout();
  });

  group('AuthCubit / LoginCubit', () {
    test('الدخول يحدّث الحالة والخروج يمسحها', () async {
      final auth = AuthCubit();
      expect(auth.state.user, isNull);
      auth.login('user1', '1234');
      await Future<void>.delayed(Duration.zero);
      expect(auth.state.user?.username, 'user1');
      auth.logout();
      await Future<void>.delayed(Duration.zero);
      expect(auth.state.user, isNull);
      await auth.close();
    });

    test('بيانات خاطئة تظهر كرسالة خطأ ولا تدخل', () {
      final auth = AuthCubit();
      final login = LoginCubit(auth);
      login.submit('user1', 'خطأ');
      expect(login.state.error, isNotNull);
      expect(auth.state.user, isNull);
      login.toggleObscure();
      expect(login.state.obscure, isFalse);
      expect(login.state.error, isNotNull, reason: 'تبديل الإخفاء لا يمسح رسالة الخطأ');
    });

    test('تذكّر كلمة المرور: يحفظ بعد نجاح الدخول فقط', () async {
      final creds = MemoryCredentialStore();
      final auth = AuthCubit();
      final login = LoginCubit(auth, credentials: creds);
      login.setRemember(true);
      await login.submit('user1', 'خطأ');
      expect(await creds.read(), isNull, reason: 'الدخول الفاشل لا يحفظ شيئاً');
      await login.submit('user1', '1234');
      final saved = await creds.read();
      expect(saved?.username, 'user1');
      expect(saved?.password, '1234');
      await auth.close();
      await login.close();
    });

    test('إلغاء الخيار يمسح المحفوظ، وloadSaved يفعّل الخيار', () async {
      final creds = MemoryCredentialStore();
      await creds.save('user1', '1234');
      final auth = AuthCubit();
      final login = LoginCubit(auth, credentials: creds);
      final saved = await login.loadSaved();
      expect(saved?.username, 'user1');
      expect(login.state.remember, isTrue);
      login.setRemember(false);
      await login.submit('user1', '1234');
      expect(await creds.read(), isNull);
      await auth.close();
      await login.close();
    });
  });

  group('HomeCubit', () {
    test('اختيار قسم يغيّر الكتب المعروضة ولا يتأثر القسم الآخر', () {
      store.login('user1', '1234');
      final cubit = HomeCubit();
      final shelves = cubit.state.paper.shelves;
      expect(shelves, isNotEmpty);
      expect(shelves.every((s) => s.books.isNotEmpty), isTrue,
          reason: 'الأقسام الفارغة لا تظهر');
      expect(cubit.state.paper.selected?.category.id, shelves.first.category.id);
      final digitalBefore = cubit.state.digital.selected?.category.id;
      if (shelves.length > 1) {
        final second = shelves[1].category.id;
        cubit.selectCategory(LibraryType.paper, second);
        final shown = cubit.state.paper.selected!;
        expect(shown.category.id, second);
        expect(shown.books.every((b) => !b.isDigital && b.categoryId == second), isTrue);
        expect(cubit.state.digital.selected?.category.id, digitalBefore);
      }
      cubit.close();
    });

    test('الاقتراحات حتى 8 كتب والبطاقة تعرض موعد الإرجاع القادم', () {
      store.login('user1', '1234');
      final cubit = HomeCubit();
      expect(cubit.state.suggestions.length, lessThanOrEqualTo(8));
      expect(cubit.state.nextLoan, cubit.state.loans.isEmpty ? isNull : isNotNull);
      cubit.close();
    });
  });

  group('بيانات الحساب', () {
    test('إدارة عامة: الحقل الأول مطلوب والثاني اختياري وتظهر في أسطر البطاقة', () {
      store.login('user1', '1234');
      expect(
        () => store.updateProfile(kind: OrgKind.general, values: ['', 'إدارة التوثيق']),
        throwsA(isA<LibraryException>()),
      );
      store.updateProfile(
        kind: OrgKind.general,
        values: ['الإدارة العامة للشؤون الفنية', 'إدارة التوثيق'],
        phone: '٠٩١٢٣٤٥٦٧٨',
      );
      final me = store.currentUser!;
      expect(me.phone, '0912345678');
      expect(me.orgLines, [
        'الإدارة العامة: الإدارة العامة للشؤون الفنية',
        'الإدارة الفرعية: إدارة التوثيق',
      ]);
    });

    test('فرع ومكتب، ورقم هاتف غير صالح يُرفض، والمسح يفرّغ الجهة', () {
      store.login('user1', '1234');
      store.updateProfile(kind: OrgKind.branch, values: ['فرع بنغازي', '']);
      expect(store.currentUser!.orgLines, ['اسم الفرع: فرع بنغازي']);
      store.updateProfile(kind: OrgKind.office, values: ['مكتب رئيس الهيئة']);
      expect(store.currentUser!.orgLines, ['المكتب: مكتب رئيس الهيئة']);
      expect(
        () => store.updateProfile(kind: OrgKind.office, values: ['مكتب'], phone: '12'),
        throwsA(isA<LibraryException>()),
      );
      store.updateProfile(kind: null);
      expect(store.currentUser!.orgLines, isEmpty);
    });
  });

  group('SearchCubit', () {
    test('التصفية بالنوع تعيد كتباً من النوع نفسه فقط', () {
      store.login('user1', '1234');
      final cubit = SearchCubit();
      cubit.setType(LibraryType.digital);
      expect(cubit.state.results, isNotEmpty);
      expect(cubit.state.results.every((b) => b.isDigital), isTrue);
      cubit.setType(LibraryType.paper);
      expect(cubit.state.results.every((b) => !b.isDigital), isTrue);
      cubit.close();
    });
  });

  group('LoansCubit', () {
    test('تتحدث القائمة عند الاستعارة تلقائياً', () async {
      store.login('user1', '1234');
      final cubit = LoansCubit();
      final before = cubit.state.entries.length;
      final book = store.books.firstWhere(
        (b) => !b.isDigital && b.isAvailable &&
            !store.activeLoansOf('user1').any((l) => l.bookId == b.id),
      );
      store.borrow(book.id);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.entries.length, before + 1);
      await cubit.close();
    });
  });

  group('ChangePasswordCubit', () {
    test('عدم التطابق يعطي خطأ والتطابق يمسحه', () {
      final cubit = ChangePasswordCubit();
      expect(cubit.validate('abcdef', 'abcdeg'), isFalse);
      expect(cubit.state.error, isNotNull);
      expect(cubit.validate('abcdef', 'abcdef'), isTrue);
      expect(cubit.state.error, isNull);
      cubit.close();
    });
  });

  group('BookFormCubit', () {
    test('الحفظ بدون غلاف يرمي خطأ تحقق', () {
      store.login('admin', '1234');
      final cubit = BookFormCubit(null);
      expect(
        () => cubit.save(title: 'كتاب', author: 'مؤلف', copiesText: '1'),
        throwsA(isA<LibraryException>()),
      );
      cubit.close();
    });
  });
}
