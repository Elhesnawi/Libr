import 'dart:typed_data';

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
      store.borrow(4);
      store.borrow(6);
      expect(() => store.borrow(7), throwsLibrary());
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
      final before = store.bookById(4)!.availableCopies;
      store.borrow(4);
      expect(store.bookById(4)!.availableCopies, before - 1);
    });

    test('الموظف يستعير لمستعير آخر والمستخدم لا يستطيع', () {
      store.login('user1', '1234');
      expect(() => store.borrow(4, forUsername: 'user2'), throwsLibrary());
      store.logout();
      store.login('lib1', '1234');
      store.borrow(4, forUsername: 'user2');
      expect(store.activeLoansOf('user2').any((l) => l.bookId == 4), isTrue);
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
      // الغلاف وتاريخ النشر إلزاميان، والكتاب الرقمي يحتاج ملف PDF.
      expect(
        () => store.addBook(
            title: 'جديد', author: 'م', categoryId: 1, isDigital: false, copies: 1),
        throwsLibrary(),
      );
      final cover = Uint8List.fromList([1, 2, 3]);
      expect(
        () => store.addBook(
          title: 'جديد',
          author: 'م',
          categoryId: 1,
          isDigital: true,
          copies: 1,
          publishDate: DateTime(2020),
          coverBytes: cover,
        ),
        throwsLibrary(),
      );
      expect(
        () => store.addBook(
          title: 'جديد',
          author: 'م',
          categoryId: 1,
          isDigital: false,
          copies: 1,
          publishDate: DateTime.now().add(const Duration(days: 5)),
          coverBytes: cover,
        ),
        throwsLibrary(),
      );
      final book = store.addBook(
        title: 'جديد',
        author: 'م',
        categoryId: 1,
        isDigital: true,
        copies: 2,
        publishDate: DateTime(2020, 5, 10),
        coverBytes: cover,
        fileName: 'new.pdf',
      );
      // الكتاب الرقمي نسخة واحدة دائماً ومتاح دائماً.
      expect(store.bookById(book.id)?.availableCopies, 1);
      expect(store.bookById(book.id)?.isAvailable, isTrue);
      expect(store.bookById(book.id)?.fileName, 'new.pdf');
      // لا يتكرر العنوان.
      expect(
        () => store.addBook(
          title: 'جديد',
          author: 'م',
          categoryId: 1,
          isDigital: false,
          copies: 1,
          publishDate: DateTime(2020),
          coverBytes: cover,
        ),
        throwsLibrary(),
      );
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
    test('تعطيل حساب بسبب: يمنع الدخول وتبقى البيانات، ثم إعادة التفعيل', () {
      store.login('admin', '1234');
      store.disableUser('user1', 'كتاب لم يُعد');
      final u = store.userByName('user1')!;
      expect(u.disabled, isTrue);
      expect(u.disabledReason, 'كتاب لم يُعد');
      expect(u.disabledAt, isNotNull);
      store.logout();

      expect(
        () => store.login('user1', '1234'),
        throwsA(isA<LibraryException>()
            .having((e) => e.message, 'message', contains('كتاب لم يُعد'))),
      );

      store.login('admin', '1234');
      store.enableUser('user1');
      expect(store.userByName('user1')!.disabled, isFalse);
      expect(store.userByName('user1')!.disabledReason, isEmpty);
      store.logout();
      store.login('user1', '1234');
      expect(store.currentUser?.username, 'user1');
    });

    test('التعطيل يتطلب سبباً، ولا يعطّل المدير نفسه ولا آخر مدير، وللمدير فقط', () {
      store.login('admin', '1234');
      expect(() => store.disableUser('user1', '  '), throwsLibrary());
      expect(() => store.disableUser('admin', 'سبب'), throwsLibrary());
      store.logout();

      store.login('lib1', '1234');
      expect(() => store.disableUser('user1', 'سبب'), throwsLibrary());
      expect(() => store.enableUser('user1'), throwsLibrary());
    });

    test('المدير المعطّل لا يُحتسب ضمن المديرين الفعّالين عند حماية آخر مدير', () {
      store.login('admin', '1234');
      store.addUser(username: 'admin2', fullName: 'مدير ثانٍ', role: UserRole.admin);
      store.disableUser('admin2', 'اختبار');
      store.logout();
      store.login('admin', '1234');
      store.enableUser('admin2');
      store.logout();

      store.login('admin2', '1234');
      store.disableUser('admin', 'اختبار');
      expect(() => store.setRole('admin', UserRole.user), throwsLibrary());
      store.logout();
    });

    test('المدير لا يغيّر دوره بنفسه ويغيّر دور غيره', () {
      store.login('admin', '1234');
      expect(() => store.setRole('admin', UserRole.user), throwsLibrary());
      store.setRole('user1', UserRole.librarian);
      expect(store.userByName('user1')!.role, UserRole.librarian);
    });

    test('ترقية مستخدم إلى مدير تخطره، والموظف لا يغيّر الصلاحيات', () {
      store.login('lib1', '1234');
      expect(() => store.setRole('user1', UserRole.admin), throwsLibrary());
      store.logout();

      store.login('admin', '1234');
      store.setRole('user1', UserRole.admin);
      expect(store.userByName('user1')!.role, UserRole.admin);
      store.logout();

      expect(
        store.notificationsOf('user1').any((n) => n.title.contains('مدير النظام')),
        isTrue,
      );
      // المدير الجديد يملك صلاحيات المدير ويستطيع إنشاء حساب.
      store.login('user1', '1234');
      store.addUser(username: 'made_by_new_admin', fullName: 'س');
      expect(store.userByName('made_by_new_admin'), isNotNull);
    });

    test('إنشاء حساب بصلاحية محددة', () {
      store.login('admin', '1234');
      store.addUser(username: 'staff9', fullName: 'موظف', role: UserRole.librarian);
      expect(store.userByName('staff9')!.role, UserRole.librarian);
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

  group('الكتب الرقمية والتقييم والتذكيرات', () {
    test('الكتاب الرقمي لا يُستعار ولا يُحجز', () {
      store.login('user1', '1234');
      expect(() => store.borrow(3), throwsLibrary());
      expect(() => store.reserve(3), throwsLibrary());
      expect(store.bookById(3)!.isAvailable, isTrue);
    });

    test('القراءة تحفظ آخر صفحة وتُرفض للورقي', () {
      store.login('user1', '1234');
      expect(store.readingPage(3), 0);
      store.setReadingPage(3, 5);
      expect(store.readingPage(3), 5);
      store.setReadingPage(3, 99);
      expect(store.readingPage(3), store.bookById(3)!.pages);
      expect(() => store.setReadingPage(1, 2), throwsLibrary());
      expect(() => store.downloadBook(1), throwsLibrary());
    });

    test('التقييم بعد الاستعارة فقط، وواحد لكل مستخدم', () {
      store.login('user1', '1234');
      expect(() => store.rateBook(7, 4), throwsLibrary()); // لم يستعره
      store.rateBook(1, 2, comment: ' عادي ');
      expect(store.myRating(1)!.stars, 2);
      expect(store.myRating(1)!.comment, 'عادي');
      expect(store.ratingsOf(1).where((r) => r.username == 'user1').length, 1);
      expect(() => store.rateBook(1, 0), throwsLibrary());
      expect(() => store.rateBook(1, 6), throwsLibrary());
      expect(store.averageRating(1), closeTo((5 + 2) / 2, 0.001));
    });

    test('الكتاب الرقمي يُقيَّم بعد قراءته أو تحميله', () {
      store.login('user1', '1234');
      expect(store.canRate(8), isFalse);
      store.downloadBook(8);
      expect(store.canRate(8), isTrue);
      store.rateBook(8, 5);
      expect(store.ratingCount(8), 1);
    });

    test('الموظف لا يقيّم ويحذف أي تقييم، والمستخدم لا يحذف', () {
      store.login('lib1', '1234');
      expect(() => store.rateBook(1, 5), throwsLibrary());
      final id = store.ratingsOf(1).first.id;
      store.logout();
      store.login('user1', '1234');
      expect(() => store.deleteRating(id), throwsLibrary());
      store.logout();
      store.login('lib1', '1234');
      store.deleteRating(id);
      expect(store.ratingsOf(1).any((r) => r.id == id), isFalse);
      expect(store.topRated().first.value, greaterThan(0));
    });

    test('تذكير الإرجاع يدوي للموظفين فقط ويصل للمستعير', () {
      store.login('user2', '1234');
      expect(() => store.remindAllDue(), throwsLibrary());
      store.logout();
      store.login('lib1', '1234');
      expect(store.remindableLoans.any((l) => l.username == 'user2'), isTrue);
      final before = store.notificationsOf('user2').length;
      expect(store.remindAllDue(), greaterThan(0));
      expect(store.notificationsOf('user2').length, before + 1);
      expect(
        store.notificationsOf('user2').any((n) => n.title.contains('تذكير')),
        isTrue,
      );
    });

    test('مرور يوم يُنشئ تنبيهاً جديداً للمتأخر', () {
      store.login('user2', '1234');
      final before = store.notificationsOf('user2').length;
      store.simulateDayPassed();
      expect(store.notificationsOf('user2').length, before + 1);
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
