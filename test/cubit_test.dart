import 'package:flutter_test/flutter_test.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/common/change_password/change_password_cubit.dart';
import 'package:librarry_app/views/login/login_cubit.dart';
import 'package:librarry_app/views/staff/book_form/book_form_cubit.dart';
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
