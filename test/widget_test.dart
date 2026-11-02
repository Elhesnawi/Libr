import 'package:flutter_test/flutter_test.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/utils/arabic_text.dart';

void main() {
  late LibraryStore store;

  setUp(() {
    store = LibraryStore.createForTest();
  });

  Matcher throwsLibrary() => throwsA(isA<LibraryException>());

  group('تسجيل الدخول', () {
    test('بيانات خاطئة أو فارغة تُرفض', () {
      expect(() => store.login('user1', 'خطأ'), throwsLibrary());
      expect(() => store.login('', ''), throwsLibrary());
      expect(() => store.login('غير_موجود', '1234'), throwsLibrary());
    });

    test('الدخول الصحيح يحدد المستخدم الحالي وآخر دخول سابق', () {
      store.login('user1', '1234');
      expect(store.currentUser?.username, 'user1');
      expect(store.previousLogin, isNotNull);
      store.logout();
      expect(store.currentUser, isNull);
    });

    test('أي عملية بدون دخول تُرفض', () {
      expect(() => store.borrow(1), throwsLibrary());
      expect(() => store.toggleFavorite(1), throwsLibrary());
    });
  });

  group('الاستعارة', () {
    test('الحد الأقصى 3 كتب', () {
      store.login('user1', '1234'); // لديه كتاب مستعار واحد
      store.borrow(3);
      store.borrow(4);
      expect(() => store.borrow(5), throwsLibrary());
    });

    test('لا تُستعار نسخة غير متاحة', () {
      store.login('user1', '1234');
      expect(() => store.borrow(2), throwsLibrary());
    });

    test('لا تُستعار نفس النسخة مرتين', () {
      store.login('user1', '1234');
      expect(() => store.borrow(1), throwsLibrary());
    });

    test('الاستعارة تنقص النسخ المتاحة', () {
      store.login('user1', '1234');
      final before = store.bookById(3)!.availableCopies;
      store.borrow(3);
      expect(store.bookById(3)!.availableCopies, before - 1);
    });

    test('الموظف يستعير لمستعير آخر والمستخدم لا يستطيع', () {
      store.login('user1', '1234');
      expect(() => store.borrow(3, forUsername: 'user2'), throwsLibrary());
      store.logout();
      store.login('lib1', '1234');
      store.borrow(3, forUsername: 'user2');
      expect(store.activeLoansOf('user2').any((l) => l.bookId == 3), isTrue);
    });
  });

  group('الإرجاع والحجز', () {
    test('المستخدم العادي لا يسجل الإرجاع ولا يمدد', () {
      store.login('user1', '1234');
      expect(() => store.returnLoan(1), throwsLibrary());
      expect(() => store.extendLoan(1), throwsLibrary());
    });

    test('الإرجاع يزيد النسخ ويخطر أول حاجز', () {
      store.login('user1', '1234');
      store.reserve(2); // الكتاب 2 غير متاح
      expect(store.hasReserved(2), isTrue);
      expect(() => store.reserve(2), throwsLibrary());
      store.logout();

      store.login('lib1', '1234');
      store.returnByScan('user2', 2);
      expect(store.bookById(2)!.availableCopies, 1);
      store.logout();

      expect(
        store.notificationsOf('user1').any((n) => n.title.contains('الوجيز')),
        isTrue,
      );
    });

    test('الإرجاع بالباركود لمستعير ليس لديه الكتاب يفشل', () {
      store.login('lib1', '1234');
      expect(() => store.returnByScan('user1', 2), throwsLibrary());
    });

    test('التمديد يضيف 7 أيام', () {
      store.login('lib1', '1234');
      final loan = store.allActiveLoans.firstWhere((l) => l.id == 1);
      final before = loan.dueAt;
      store.extendLoan(1);
      expect(loan.dueAt.difference(before).inDays, LibraryStore.extendDays);
    });

    test('المتأخر يُخطَر عند الدخول', () {
      store.login('user2', '1234');
      expect(
        store.notificationsOf('user2').any((n) => n.title.contains('تأخر')),
        isTrue,
      );
    });
  });

  group('الكتب والأقسام', () {
    test('لا يُحذف كتاب مستعار، ويُحذف غير المستعار', () {
      store.login('lib1', '1234');
      expect(() => store.deleteBook(1), throwsLibrary());
      store.deleteBook(10);
      expect(store.bookById(10), isNull);
    });

    test('المستخدم العادي لا يضيف كتاباً', () {
      store.login('user1', '1234');
      expect(
        () => store.addBook(
          title: 'ت',
          author: 'م',
          categoryId: 1,
          isDigital: false,
          copies: 1,
        ),
        throwsLibrary(),
      );
    });

    test('إضافة كتاب تتحقق من المدخلات', () {
      store.login('lib1', '1234');
      expect(
        () => store.addBook(
            title: '', author: 'م', categoryId: 1, isDigital: false, copies: 1),
        throwsLibrary(),
      );
      expect(
        () => store.addBook(
            title: 'ت', author: 'م', categoryId: 1, isDigital: false, copies: 0),
        throwsLibrary(),
      );
      final book = store.addBook(
          title: 'جديد', author: 'م', categoryId: 1, isDigital: true, copies: 2);
      expect(store.bookById(book.id)?.availableCopies, 2);
    });

    test('تعديل النسخ لا ينزل عن المستعار حالياً', () {
      store.login('lib1', '1234');
      // الكتاب 1: نسختان من ثلاث متاحتان، أي واحدة مستعارة.
      expect(
        () => store.updateBook(1,
            title: 'ع', author: 'م', categoryId: 1, isDigital: false, copies: 0),
        throwsLibrary(),
      );
      store.updateBook(1,
          title: 'عنوان جديد', author: 'م', categoryId: 1, isDigital: false, copies: 5);
      expect(store.bookById(1)!.availableCopies, 4);
    });

    test('حذف القسم للمدير فقط ولا يُحذف قسم فيه كتب', () {
      store.login('lib1', '1234');
      expect(() => store.deleteCategory(1), throwsLibrary());
      final cat = store.addCategory('قسم تجريبي');
      expect(() => store.addCategory('قسم تجريبي'), throwsLibrary());
      store.logout();

      store.login('admin', '1234');
      expect(() => store.deleteCategory(1), throwsLibrary());
      store.deleteCategory(cat.id);
      expect(store.categoryById(cat.id), isNull);
    });
  });

  group('الحسابات', () {
    test('المدير لا يغيّر دوره بنفسه ويغيّر دور غيره', () {
      store.login('admin', '1234');
      expect(() => store.setRole('admin', UserRole.user), throwsLibrary());
      store.setRole('user1', UserRole.librarian);
      expect(store.userByName('user1')!.role, UserRole.librarian);
    });

    test('إنشاء حساب: تكرار ومدخلات', () {
      store.login('admin', '1234');
      expect(() => store.addUser(username: 'user1', fullName: 'س'), throwsLibrary());
      expect(() => store.addUser(username: 'حرف عربي', fullName: 'س'), throwsLibrary());
      store.addUser(username: 'new1', fullName: 'جديد');
      store.logout();
      store.login('new1', LibraryStore.tempPassword);
      expect(store.currentUser?.fullName, 'جديد');
    });

    test('تغيير كلمة المرور', () {
      store.login('user1', '1234');
      expect(
        () => store.changePassword(oldPassword: 'x', newPassword: '123456'),
        throwsLibrary(),
      );
      expect(
        () => store.changePassword(oldPassword: '1234', newPassword: '123'),
        throwsLibrary(),
      );
      store.changePassword(oldPassword: '1234', newPassword: '654321');
      store.logout();
      expect(() => store.login('user1', '1234'), throwsLibrary());
      store.login('user1', '654321');
      expect(store.currentUser?.username, 'user1');
    });
  });

  group('الطلبات والإعلانات', () {
    test('قبول الطلب يخطر صاحبه', () {
      store.login('user1', '1234');
      store.submitRequest(title: 'كتاب مقترح', author: 'مؤلف');
      store.logout();

      store.login('lib1', '1234');
      final req = store.allRequests.firstWhere((r) => r.username == 'user1');
      store.decideRequest(req.id, accepted: true);
      expect(() => store.decideRequest(req.id, accepted: false), throwsLibrary());
      store.logout();

      expect(
        store.notificationsOf('user1').any((n) => n.title.contains('تم قبول')),
        isTrue,
      );
    });

    test('الإعلانات للموظفين فقط', () {
      store.login('user1', '1234');
      expect(() => store.addAnnouncement('نص'), throwsLibrary());
      store.logout();
      store.login('lib1', '1234');
      store.addAnnouncement('إعلان جديد');
      expect(store.announcements.first.text, 'إعلان جديد');
    });
  });

  group('البحث والإحصائيات', () {
    test('البحث يتجاهل الهمزات والتشكيل', () {
      final results = store.search(query: 'الاداري');
      expect(results, isNotEmpty);
      expect(results.any((b) => b.title.contains('الإداري')), isTrue);
      expect(normalizeArabic('الإِدَارِيّ'), normalizeArabic('الاداري'));
    });

    test('التصفية بالنوع', () {
      final digital = store.search(type: LibraryType.digital);
      expect(digital.every((b) => b.isDigital), isTrue);
      final paper = store.search(type: LibraryType.paper);
      expect(paper.every((b) => !b.isDigital), isTrue);
    });

    test('الإحصائيات لا ترمي استثناء حتى بدون دخول', () {
      final s = store.stats();
      expect(s.books, 10);
      expect(s.lateLoans, 1);
      expect(store.topBooks().first.value, greaterThan(0));
      expect(store.monthlyLoans().length, 6);
    });

    test('اقتراحات المستخدم الجديد هي الأكثر استعارة', () {
      expect(store.suggestionsFor('مستخدم_بلا_نشاط'), isNotEmpty);
    });
  });
}
