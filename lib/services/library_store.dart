import 'dart:typed_data';

import 'package:flutter/foundation.dart' show ChangeNotifier, visibleForTesting;
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/models/library_type.dart';
import 'package:librarry_app/utils/arabic_text.dart';

/// مخزن بيانات المكتبة (محلي ومؤقت في الذاكرة).
///
/// كل القواعد (الصلاحيات، حد الاستعارة، منع حذف كتاب مستعار...) مكتوبة هنا،
/// وهي نفس القواعد الموجودة في ملف قاعدة بيانات Supabase، لذلك عند الربط لاحقاً
/// نستبدل داخل هذا الملف فقط ولا تتغير الشاشات.
class LibraryStore extends ChangeNotifier {
  LibraryStore._() {
    _seed();
  }

  static final LibraryStore instance = LibraryStore._();

  /// نسخة جديدة نظيفة للاختبارات.
  @visibleForTesting
  factory LibraryStore.createForTest() => LibraryStore._();

  static const int maxLoans = 3;
  static const int loanDays = 14;
  static const int extendDays = 7;
  static const String tempPassword = '123456';
  static const int minPasswordLength = 6;

  final List<AppUser> _users = [];
  final List<BookCategory> _categories = [];
  final List<Book> _books = [];
  final List<Loan> _loans = [];
  final List<BookRequest> _requests = [];
  final List<Announcement> _announcements = [];
  final List<AppNotification> _notifications = [];
  final List<LogEntry> _logs = [];
  final Map<String, Set<int>> _favorites = {};
  final Map<int, int> _borrowCounts = {};
  final Map<int, List<String>> _reservations = {};
  final Set<String> _notified = {};
  final List<Rating> _ratings = [];
  final Map<String, int> _progress = {};
  final Set<String> _downloads = {};

  AppUser? _current;
  DateTime? _previousLogin;
  bool _darkMode = false;
  int _nextId = 1000;

  // ───────────────────────── قراءة عامة ─────────────────────────

  AppUser? get currentUser => _current;

  /// آخر دخول سابق للمستخدم الحالي (قبل هذه الجلسة).
  DateTime? get previousLogin => _previousLogin;

  bool get darkMode => _darkMode;

  List<AppUser> get users => List.unmodifiable(_users);
  List<BookCategory> get categories => List.unmodifiable(_categories);
  List<Book> get books => List.unmodifiable(_books);
  List<LogEntry> get logs => List.unmodifiable(_logs);

  List<Announcement> get announcements => List.unmodifiable(_announcements);

  BookCategory? categoryById(int id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Book? bookById(int id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  AppUser? userByName(String username) {
    for (final u in _users) {
      if (u.username == username) return u;
    }
    return null;
  }

  // ───────────────────────── الدخول والخروج ─────────────────────────

  void login(String username, String password) {
    final name = username.trim().toLowerCase();
    if (name.isEmpty || password.isEmpty) {
      throw const LibraryException('أدخل اسم المستخدم وكلمة المرور');
    }
    final user = userByName(name);
    if (user == null || user.password != password) {
      throw const LibraryException('اسم المستخدم أو كلمة المرور غير صحيحة');
    }
    if (user.disabled) {
      throw LibraryException(
        'هذا الحساب معطّل. السبب: ${user.disabledReason}. راجع مدير النظام',
      );
    }
    _previousLogin = user.lastLogin;
    user.lastLogin = DateTime.now();
    _current = user;
    _refreshDueNotifications(user);
    notifyListeners();
  }

  void logout() {
    _current = null;
    _previousLogin = null;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  /// يحفظ بيانات حساب المستخدم الحالي: جهة العمل ورقم الهاتف (كلاهما اختياري).
  /// عند اختيار نوع جهة يلزم حقله الأول، والثاني اختياري.
  void updateProfile({
    required OrgKind? kind,
    List<String> values = const [],
    String phone = '',
  }) {
    final me = _requireLogin();
    var vals = <String>[];
    if (kind != null) {
      final labels = kind.fieldLabels;
      vals = [
        for (var i = 0; i < labels.length; i++)
          i < values.length ? values[i].trim() : '',
      ];
      if (vals.first.isEmpty) {
        throw LibraryException('أدخل ${labels.first}');
      }
    }
    final digits = _normalizeDigits(phone).replaceAll(RegExp(r'[\s\-+()]'), '');
    if (digits.isNotEmpty && !RegExp(r'^\d{9,15}$').hasMatch(digits)) {
      throw const LibraryException('رقم الهاتف غير صحيح (من 9 إلى 15 رقماً)');
    }
    me.orgKind = kind;
    me.orgValues = vals;
    me.phone = digits;
    _log('تحديث بيانات الحساب');
    notifyListeners();
  }

  /// يحوّل الأرقام العربية والهندية إلى أرقام لاتينية.
  static String _normalizeDigits(String s) {
    final b = StringBuffer();
    for (final r in s.runes) {
      if (r >= 0x0660 && r <= 0x0669) {
        b.writeCharCode(r - 0x0660 + 48);
      } else if (r >= 0x06F0 && r <= 0x06F9) {
        b.writeCharCode(r - 0x06F0 + 48);
      } else {
        b.writeCharCode(r);
      }
    }
    return b.toString();
  }

  // ───────────────────────── حراس الصلاحيات ─────────────────────────

  AppUser _requireLogin() {
    final u = _current;
    if (u == null) throw const LibraryException('سجّل الدخول أولاً');
    return u;
  }

  AppUser _requireStaff() {
    final u = _requireLogin();
    if (!u.role.isStaff) {
      throw const LibraryException('هذه العملية للموظفين فقط');
    }
    return u;
  }

  AppUser _requireAdmin() {
    final u = _requireLogin();
    if (u.role != UserRole.admin) {
      throw const LibraryException('هذه العملية للمدير فقط');
    }
    return u;
  }

  // ───────────────────────── البحث والتصفح ─────────────────────────

  List<Book> search({
    String query = '',
    int? categoryId,
    LibraryType? type,
  }) {
    final q = normalizeArabic(query);
    return _books.where((b) {
      if (categoryId != null && b.categoryId != categoryId) return false;
      if (type == LibraryType.digital && !b.isDigital) return false;
      if (type == LibraryType.paper && b.isDigital) return false;
      if (q.isEmpty) return true;
      return normalizeArabic(b.title).contains(q) ||
          normalizeArabic(b.author).contains(q);
    }).toList();
  }

  List<Book> booksIn(int categoryId, LibraryType type) =>
      search(categoryId: categoryId, type: type);

  int countIn(int categoryId, LibraryType type) =>
      booksIn(categoryId, type).length;

  // ───────────────────────── المفضلة ─────────────────────────

  Set<int> _favSet(String username) =>
      _favorites.putIfAbsent(username, () => <int>{});

  bool isFavorite(int bookId) {
    final u = _current;
    if (u == null) return false;
    return _favSet(u.username).contains(bookId);
  }

  List<Book> favoriteBooks() {
    final u = _current;
    if (u == null) return [];
    final ids = _favSet(u.username);
    return _books.where((b) => ids.contains(b.id)).toList();
  }

  int get favoritesCount => favoriteBooks().length;

  /// يعيد الحالة الجديدة (true = أُضيف للمفضلة).
  bool toggleFavorite(int bookId) {
    final u = _requireLogin();
    final set = _favSet(u.username);
    final added = !set.remove(bookId);
    if (added) set.add(bookId);
    notifyListeners();
    return added;
  }

  // ───────────────────────── الاستعارة والإرجاع ─────────────────────────

  List<Loan> activeLoansOf(String username) {
    final list =
        _loans.where((l) => l.isActive && l.username == username).toList();
    list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return list;
  }

  List<Loan> historyOf(String username) {
    final list =
        _loans.where((l) => !l.isActive && l.username == username).toList();
    list.sort((a, b) => b.returnedAt!.compareTo(a.returnedAt!));
    return list;
  }

  List<Loan> get allActiveLoans {
    final list = _loans.where((l) => l.isActive).toList();
    list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return list;
  }

  List<Loan> get lateLoans => allActiveLoans.where((l) => l.isOverdue).toList();

  /// الاستعارة للمستخدم الحالي، أو (للموظف فقط) لمستعير آخر عبر [forUsername].
  Loan borrow(int bookId, {String? forUsername}) {
    final me = _requireLogin();
    final target = forUsername ?? me.username;
    final self = target == me.username;
    if (!self) _requireStaff();
    if (userByName(target) == null) {
      throw const LibraryException('المستعير غير موجود');
    }
    final book = _mustBook(bookId);
    if (book.isDigital) {
      throw const LibraryException('الكتب الرقمية تُقرأ وتُحمَّل مباشرة بلا استعارة');
    }
    final active = activeLoansOf(target);
    if (active.length >= maxLoans) {
      throw LibraryException(self
          ? 'وصلت إلى الحد الأقصى: $maxLoans كتب'
          : 'المستعير وصل إلى الحد الأقصى: $maxLoans كتب');
    }
    if (active.any((l) => l.bookId == bookId)) {
      throw const LibraryException('هذا الكتاب مستعار بالفعل');
    }
    if (!book.isAvailable) {
      throw const LibraryException('لا توجد نسخة متاحة الآن، يمكنك حجزه');
    }
    book.availableCopies -= 1;
    _borrowCounts[bookId] = (_borrowCounts[bookId] ?? 0) + 1;
    _reservations[bookId]?.remove(target);
    final now = DateTime.now();
    final loan = Loan(
      id: _nextId++,
      bookId: bookId,
      username: target,
      borrowedAt: now,
      dueAt: now.add(const Duration(days: loanDays)),
    );
    _loans.add(loan);
    _log('استعارة كتاب: ${book.title} ($target)');
    notifyListeners();
    return loan;
  }

  void returnLoan(int loanId) {
    _requireStaff();
    final loan = _mustLoan(loanId);
    if (!loan.isActive) {
      throw const LibraryException('تم إرجاع هذا الكتاب مسبقاً');
    }
    final book = _mustBook(loan.bookId);
    loan.returnedAt = DateTime.now();
    if (book.availableCopies < book.totalCopies) book.availableCopies += 1;
    _log('إرجاع كتاب: ${book.title} (${loan.username})');
    _notifyFirstReservation(book);
    notifyListeners();
  }

  /// الإرجاع بالباركود: يحدد الاستعارة من اسم المستعير ورمز الكتاب.
  void returnByScan(String username, int bookId) {
    _requireStaff();
    for (final l in _loans) {
      if (l.isActive && l.username == username && l.bookId == bookId) {
        returnLoan(l.id);
        return;
      }
    }
    throw const LibraryException('لا توجد استعارة لهذا المستعير بهذا الكتاب');
  }

  void extendLoan(int loanId) {
    _requireStaff();
    final loan = _mustLoan(loanId);
    if (!loan.isActive) {
      throw const LibraryException('لا يمكن تمديد كتاب تم إرجاعه');
    }
    loan.dueAt = loan.dueAt.add(const Duration(days: extendDays));
    _log('تمديد موعد: ${_mustBook(loan.bookId).title} (${loan.username})');
    notifyListeners();
  }

  // ───────────────────────── الحجز ─────────────────────────

  bool hasReserved(int bookId) {
    final u = _current;
    if (u == null) return false;
    return _reservations[bookId]?.contains(u.username) ?? false;
  }

  void reserve(int bookId) {
    final me = _requireLogin();
    final book = _mustBook(bookId);
    if (book.isAvailable) {
      throw const LibraryException('الكتاب متاح الآن، يمكنك استعارته مباشرة');
    }
    final queue = _reservations.putIfAbsent(bookId, () => <String>[]);
    if (queue.contains(me.username)) {
      throw const LibraryException('حجزت هذا الكتاب مسبقاً');
    }
    queue.add(me.username);
    _log('حجز كتاب: ${book.title}');
    notifyListeners();
  }

  void _notifyFirstReservation(Book book) {
    final queue = _reservations[book.id];
    if (queue == null || queue.isEmpty || !book.isAvailable) return;
    final first = queue.removeAt(0);
    _addNotification(
      first,
      'أصبح كتاب "${book.title}" متاحاً',
      'كان محجوزاً لك',
    );
  }

  // ───────────────────────── الكتب والأقسام (للموظفين) ─────────────────────────

  Book addBook({
    required String title,
    required String author,
    required int categoryId,
    required bool isDigital,
    required int copies,
    DateTime? publishDate,
    Uint8List? coverBytes,
    String? fileName,
  }) {
    _requireStaff();
    _validateBook(title, author, categoryId, copies);
    _validatePublishDate(publishDate);
    if (coverBytes == null || coverBytes.isEmpty) {
      throw const LibraryException('أضف صورة غلاف الكتاب');
    }
    if (isDigital && (fileName == null || fileName.trim().isEmpty)) {
      throw const LibraryException('ارفع ملف الكتاب الرقمي (PDF)');
    }
    final norm = normalizeArabic(title);
    if (_books.any((b) => normalizeArabic(b.title) == norm)) {
      throw const LibraryException('يوجد كتاب بنفس العنوان');
    }
    final total = isDigital ? 1 : copies;
    final book = Book(
      id: _nextId++,
      title: title.trim(),
      author: author.trim(),
      categoryId: categoryId,
      isDigital: isDigital,
      totalCopies: total,
      availableCopies: total,
      publishDate: publishDate,
      coverBytes: coverBytes,
      fileName: isDigital ? fileName!.trim() : null,
    );
    _books.add(book);
    _log('إضافة كتاب: ${book.title}');
    notifyListeners();
    return book;
  }

  void updateBook(
    int id, {
    required String title,
    required String author,
    required int categoryId,
    required bool isDigital,
    required int copies,
    DateTime? publishDate,
    Uint8List? coverBytes,
    String? fileName,
  }) {
    _requireStaff();
    final book = _mustBook(id);
    _validateBook(title, author, categoryId, copies);
    _validatePublishDate(publishDate ?? book.publishDate);
    final borrowed = book.totalCopies - book.availableCopies;
    if (isDigital && !book.isDigital && borrowed > 0) {
      throw const LibraryException('لا يمكن تحويل كتاب مستعار حالياً إلى رقمي');
    }
    final newFile = (fileName ?? book.fileName)?.trim();
    if (isDigital && (newFile == null || newFile.isEmpty)) {
      throw const LibraryException('ارفع ملف الكتاب الرقمي (PDF)');
    }
    final total = isDigital ? 1 : copies;
    if (total < borrowed) {
      throw LibraryException(
        'عدد النسخ أقل من النسخ المستعارة حالياً ($borrowed)',
      );
    }
    book.title = title.trim();
    book.author = author.trim();
    book.categoryId = categoryId;
    book.isDigital = isDigital;
    book.totalCopies = total;
    book.availableCopies = total - borrowed;
    if (publishDate != null) book.publishDate = publishDate;
    if (coverBytes != null && coverBytes.isNotEmpty) book.coverBytes = coverBytes;
    book.fileName = isDigital ? newFile : null;
    _log('تعديل كتاب: ${book.title}');
    _notifyFirstReservation(book);
    notifyListeners();
  }

  void deleteBook(int id) {
    _requireStaff();
    final book = _mustBook(id);
    if (_loans.any((l) => l.isActive && l.bookId == id)) {
      throw const LibraryException('لا يمكن حذف كتاب مستعار حالياً');
    }
    _books.remove(book);
    _loans.removeWhere((l) => l.bookId == id);
    for (final set in _favorites.values) {
      set.remove(id);
    }
    _reservations.remove(id);
    _borrowCounts.remove(id);
    _ratings.removeWhere((r) => r.bookId == id);
    _log('حذف كتاب: ${book.title}');
    notifyListeners();
  }

  void _validatePublishDate(DateTime? date) {
    if (date == null) {
      throw const LibraryException('أدخل تاريخ النشر');
    }
    if (date.isAfter(DateTime.now())) {
      throw const LibraryException('تاريخ النشر لا يكون في المستقبل');
    }
  }

  void _validateBook(String title, String author, int categoryId, int copies) {
    if (title.trim().isEmpty || author.trim().isEmpty) {
      throw const LibraryException('أدخل عنوان الكتاب واسم المؤلف');
    }
    if (categoryById(categoryId) == null) {
      throw const LibraryException('اختر قسماً صحيحاً');
    }
    if (copies < 1) {
      throw const LibraryException('عدد النسخ يجب أن يكون 1 أو أكثر');
    }
  }

  BookCategory addCategory(String name, {String iconKey = 'folder'}) {
    _requireStaff();
    final clean = name.trim();
    if (clean.isEmpty) throw const LibraryException('أدخل اسم القسم');
    final norm = normalizeArabic(clean);
    if (_categories.any((c) => normalizeArabic(c.name) == norm)) {
      throw const LibraryException('هذا القسم موجود مسبقاً');
    }
    final cat = BookCategory(id: _nextId++, name: clean, iconKey: iconKey);
    _categories.add(cat);
    _log('إضافة قسم: $clean');
    notifyListeners();
    return cat;
  }

  void deleteCategory(int id) {
    _requireAdmin();
    final cat = categoryById(id);
    if (cat == null) throw const LibraryException('القسم غير موجود');
    if (_books.any((b) => b.categoryId == id)) {
      throw const LibraryException('لا يمكن حذف قسم فيه كتب');
    }
    _categories.remove(cat);
    _log('حذف قسم: ${cat.name}');
    notifyListeners();
  }

  // ───────────────────────── طلبات الكتب ─────────────────────────

  List<BookRequest> requestsOf(String username) =>
      _requests.where((r) => r.username == username).toList().reversed.toList();

  List<BookRequest> get allRequests => _requests.reversed.toList();

  int get pendingRequestsCount =>
      _requests.where((r) => r.status == RequestStatus.pending).length;

  void submitRequest({required String title, String author = ''}) {
    final me = _requireLogin();
    if (title.trim().isEmpty) {
      throw const LibraryException('أدخل عنوان الكتاب المقترح');
    }
    _requests.add(BookRequest(
      id: _nextId++,
      username: me.username,
      title: title.trim(),
      author: author.trim().isEmpty ? 'غير محدد' : author.trim(),
    ));
    _log('طلب كتاب جديد: ${title.trim()}');
    notifyListeners();
  }

  void decideRequest(int id, {required bool accepted}) {
    _requireStaff();
    final req = _requests.firstWhere(
      (r) => r.id == id,
      orElse: () => throw const LibraryException('الطلب غير موجود'),
    );
    if (req.status != RequestStatus.pending) {
      throw const LibraryException('تمت معالجة هذا الطلب مسبقاً');
    }
    req.status = accepted ? RequestStatus.accepted : RequestStatus.rejected;
    _addNotification(
      req.username,
      accepted
          ? 'تم قبول طلبك لشراء كتاب "${req.title}"'
          : 'تعذر قبول طلبك لشراء كتاب "${req.title}"',
      'من أمين المكتبة',
    );
    _log('${accepted ? 'قبول' : 'رفض'} طلب كتاب: ${req.title}');
    notifyListeners();
  }

  // ───────────────────────── الإعلانات ─────────────────────────

  void addAnnouncement(String text) {
    _requireStaff();
    if (text.trim().isEmpty) throw const LibraryException('اكتب نص الإعلان');
    _announcements.insert(
      0,
      Announcement(id: _nextId++, text: text.trim(), date: DateTime.now()),
    );
    _log('نشر إعلان');
    notifyListeners();
  }

  void deleteAnnouncement(int id) {
    _requireStaff();
    _announcements.removeWhere((a) => a.id == id);
    _log('حذف إعلان');
    notifyListeners();
  }

  // ───────────────────────── الحسابات (للمدير) ─────────────────────────

  void addUser({
    required String username,
    required String fullName,
    UserRole role = UserRole.user,
  }) {
    _requireAdmin();
    final name = username.trim().toLowerCase();
    if (name.isEmpty || fullName.trim().isEmpty) {
      throw const LibraryException('أدخل الاسم واسم المستخدم');
    }
    if (!RegExp(r'^[a-z0-9_.-]+$').hasMatch(name)) {
      throw const LibraryException(
        'اسم المستخدم بأحرف إنجليزية صغيرة وأرقام فقط',
      );
    }
    if (userByName(name) != null) {
      throw const LibraryException('اسم المستخدم مستخدم مسبقاً');
    }
    _users.add(AppUser(
      username: name,
      fullName: fullName.trim(),
      role: role,
      password: tempPassword,
    ));
    _log('إنشاء حساب: $name (${role.shortLabel})');
    notifyListeners();
  }

  void setRole(String username, UserRole role) {
    final me = _requireAdmin();
    if (username == me.username) {
      throw const LibraryException('لا يمكنك تغيير دورك بنفسك');
    }
    final user = userByName(username);
    if (user == null) throw const LibraryException('المستخدم غير موجود');
    if (user.role == role) return;
    if (user.role == UserRole.admin &&
        role != UserRole.admin &&
        _activeAdmins < 2) {
      throw const LibraryException('لا يمكن إزالة آخر مدير للنظام');
    }
    user.role = role;
    _addNotification(username, 'تم تغيير صلاحيتك إلى ${role.label}', 'من مدير النظام');
    _log('تغيير دور $username إلى ${role.shortLabel}');
    notifyListeners();
  }

  /// إعادة تعيين كلمة مرور أي حساب آخر. للمدير فقط.
  /// يصل صاحب الحساب إشعار ليغيّرها بعد الدخول، وتُسجَّل العملية.
  void resetPassword(String username, String newPassword) {
    final me = _requireAdmin();
    if (username == me.username) {
      throw const LibraryException('غيّر كلمة مرورك من «بيانات حسابي»');
    }
    final user = userByName(username);
    if (user == null) throw const LibraryException('المستخدم غير موجود');
    if (newPassword.length < minPasswordLength) {
      throw const LibraryException('كلمة المرور يجب ألا تقل عن 6 أحرف');
    }
    user.password = newPassword;
    _addNotification(
      username,
      'أُعيد تعيين كلمة مرورك',
      'غيّرها من «بيانات حسابي» بعد الدخول',
    );
    _log('إعادة تعيين كلمة مرور $username');
    notifyListeners();
  }

  int get _activeAdmins =>
      _users.where((u) => u.role == UserRole.admin && !u.disabled).length;

  /// تعطيل حساب (مع سبب إلزامي) بدل حذفه. للمدير فقط.
  /// لا يُحذف شيء من بيانات الحساب، ويمكن إعادة تفعيله بـ [enableUser].
  void disableUser(String username, String reason) {
    final me = _requireAdmin();
    final why = reason.trim();
    if (why.isEmpty) throw const LibraryException('اكتب سبب التعطيل');
    if (username == me.username) {
      throw const LibraryException('لا يمكنك تعطيل حسابك بنفسك');
    }
    final user = userByName(username);
    if (user == null) throw const LibraryException('المستخدم غير موجود');
    if (user.disabled) throw const LibraryException('الحساب معطّل مسبقاً');
    if (user.role == UserRole.admin && _activeAdmins < 2) {
      throw const LibraryException('لا يمكن تعطيل آخر مدير للنظام');
    }
    user.disabled = true;
    user.disabledReason = why;
    user.disabledAt = DateTime.now();
    _log('تعطيل حساب $username. السبب: $why');
    notifyListeners();
  }

  /// إعادة تفعيل حساب معطّل. للمدير فقط.
  void enableUser(String username) {
    _requireAdmin();
    final user = userByName(username);
    if (user == null) throw const LibraryException('المستخدم غير موجود');
    if (!user.disabled) return;
    user.disabled = false;
    user.disabledReason = '';
    user.disabledAt = null;
    _addNotification(username, 'تمت إعادة تفعيل حسابك', 'من مدير النظام');
    _log('إعادة تفعيل حساب $username');
    notifyListeners();
  }

  void changePassword({required String oldPassword, required String newPassword}) {
    final me = _requireLogin();
    if (me.password != oldPassword) {
      throw const LibraryException('كلمة المرور الحالية غير صحيحة');
    }
    if (newPassword.length < minPasswordLength) {
      throw const LibraryException('كلمة المرور الجديدة يجب ألا تقل عن 6 أحرف');
    }
    me.password = newPassword;
    _log('تغيير كلمة المرور');
    notifyListeners();
  }

  // ───────────────────────── الإشعارات ─────────────────────────

  List<AppNotification> notificationsOf(String username) {
    final list = _notifications.where((n) => n.username == username).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int unreadCount(String username) =>
      _notifications.where((n) => n.username == username && !n.read).length;

  void markAllRead(String username) {
    var changed = false;
    for (final n in _notifications) {
      if (n.username == username && !n.read) {
        n.read = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void _addNotification(String username, String title, String subtitle) {
    _notifications.add(AppNotification(
      id: _nextId++,
      username: username,
      title: title,
      subtitle: subtitle,
      createdAt: DateTime.now(),
    ));
  }

  void _notifyOnce(String key, String username, String title, String subtitle) {
    if (_notified.add(key)) _addNotification(username, title, subtitle);
  }

  void _refreshDueNotifications(AppUser user) {
    for (final loan in activeLoansOf(user.username)) {
      final book = bookById(loan.bookId);
      if (book == null) continue;
      if (loan.isOverdue) {
        _notifyOnce('late:${loan.id}:${loan.daysLeft}', user.username,
            'تأخر إرجاع "${book.title}"', dueText(loan.daysLeft));
      } else if (loan.daysLeft <= 3) {
        _notifyOnce('due:${loan.id}:${loan.daysLeft}', user.username,
            'اقترب موعد إرجاع "${book.title}"', dueText(loan.daysLeft));
      }
    }
  }

  // ───────────────────────── التذكيرات (للموظفين) ─────────────────────────

  /// المتأخرون ومن يحين موعد إرجاعهم اليوم أو غداً.
  List<Loan> get remindableLoans =>
      allActiveLoans.where((l) => l.daysLeft <= 1).toList();

  void _sendReminder(Loan loan) {
    final book = _mustBook(loan.bookId);
    _addNotification(
      loan.username,
      loan.isOverdue
          ? 'تذكير: تأخر إرجاع "${book.title}"'
          : 'تذكير: حان موعد إرجاع "${book.title}"',
      'رسالة من أمين المكتبة · ${dueText(loan.daysLeft)}',
    );
  }

  void remindLoan(int loanId) {
    _requireStaff();
    final loan = _mustLoan(loanId);
    if (!loan.isActive) {
      throw const LibraryException('تم إرجاع هذا الكتاب مسبقاً');
    }
    _sendReminder(loan);
    _log('تذكير إرجاع: ${_mustBook(loan.bookId).title} (${loan.username})');
    notifyListeners();
  }

  /// يرسل تذكيراً لكل من يستحق، ويعيد عددهم.
  int remindAllDue() {
    _requireStaff();
    final list = remindableLoans;
    for (final l in list) {
      _sendReminder(l);
    }
    if (list.isNotEmpty) {
      _log('تذكير إرجاع لـ ${list.length} مستعير');
      notifyListeners();
    }
    return list.length;
  }

  /// أداة للتجربة فقط: تقدّم الوقت يوماً لرؤية التنبيهات الجديدة.
  void simulateDayPassed() {
    _requireLogin();
    for (final l in _loans) {
      if (l.isActive) l.dueAt = l.dueAt.subtract(const Duration(days: 1));
    }
    for (final u in _users) {
      _refreshDueNotifications(u);
    }
    notifyListeners();
  }

  // ───────────────────────── التقييمات ─────────────────────────

  List<Rating> ratingsOf(int bookId) =>
      _ratings.where((r) => r.bookId == bookId).toList().reversed.toList();

  int ratingCount(int bookId) => _ratings.where((r) => r.bookId == bookId).length;

  double averageRating(int bookId) {
    final list = _ratings.where((r) => r.bookId == bookId).toList();
    if (list.isEmpty) return 0;
    return list.fold<int>(0, (sum, r) => sum + r.stars) / list.length;
  }

  Rating? myRating(int bookId) {
    final me = _current;
    if (me == null) return null;
    for (final r in _ratings) {
      if (r.bookId == bookId && r.username == me.username) return r;
    }
    return null;
  }

  String _key(int bookId) => '${_current?.username}:$bookId';

  /// يقيّم المستخدم العادي كتاباً استعاره، أو كتاباً رقمياً قرأه أو حمّله.
  bool canRate(int bookId) {
    final me = _current;
    if (me == null || me.role.isStaff) return false;
    final borrowed = _loans.any((l) => l.username == me.username && l.bookId == bookId);
    final key = _key(bookId);
    return borrowed || _progress.containsKey(key) || _downloads.contains(key);
  }

  void rateBook(int bookId, int stars, {String comment = ''}) {
    final me = _requireLogin();
    final book = _mustBook(bookId);
    if (!canRate(bookId)) {
      throw LibraryException(book.isDigital
          ? 'يمكنك تقييم الكتاب بعد قراءته أو تحميله'
          : 'يمكنك تقييم الكتاب بعد استعارته');
    }
    if (stars < 1 || stars > 5) {
      throw const LibraryException('اختر عدد النجوم');
    }
    final existing = myRating(bookId);
    if (existing != null) {
      existing.stars = stars;
      existing.comment = comment.trim();
    } else {
      _ratings.add(Rating(
        id: _nextId++,
        bookId: bookId,
        username: me.username,
        stars: stars,
        comment: comment.trim(),
      ));
    }
    _log('تقييم كتاب: ${book.title} ($stars/5)');
    notifyListeners();
  }

  void deleteRating(int id) {
    _requireStaff();
    final before = _ratings.length;
    _ratings.removeWhere((r) => r.id == id);
    if (_ratings.length == before) {
      throw const LibraryException('التقييم غير موجود');
    }
    _log('حذف تقييم');
    notifyListeners();
  }

  /// الكتب الأعلى تقييماً (التي لها تقييم واحد على الأقل).
  List<MapEntry<Book, double>> topRated({int limit = 4}) {
    final list = <MapEntry<Book, double>>[
      for (final b in _books)
        if (ratingCount(b.id) > 0) MapEntry(b, averageRating(b.id)),
    ];
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }

  // ───────────────────────── القراءة والتحميل (الكتب الرقمية) ─────────────────────────

  Book _mustDigital(int bookId) {
    final book = _mustBook(bookId);
    if (!book.isDigital) {
      throw const LibraryException('هذا الكتاب ورقي');
    }
    return book;
  }

  /// آخر صفحة وصل إليها المستخدم الحالي (0 = لم يبدأ القراءة).
  int readingPage(int bookId) => _progress[_key(bookId)] ?? 0;

  void setReadingPage(int bookId, int page) {
    _requireLogin();
    final book = _mustDigital(bookId);
    _progress[_key(bookId)] = page.clamp(1, book.pages).toInt();
    notifyListeners();
  }

  /// تحميل الكتاب الرقمي. الملف الفعلي يأتي مع الربط بالتخزين السحابي.
  void downloadBook(int bookId) {
    _requireLogin();
    final book = _mustDigital(bookId);
    _downloads.add(_key(bookId));
    _log('تحميل كتاب: ${book.title}');
    notifyListeners();
  }

  // ───────────────────────── الإحصائيات والتقارير ─────────────────────────

  /// لا ترمي استثناء حتى لا تنهار لوحة التحكم.
  LibraryStats stats() => LibraryStats(
        books: _books.length,
        activeLoans: allActiveLoans.length,
        lateLoans: lateLoans.length,
        users: _users.length,
        pendingRequests: pendingRequestsCount,
      );

  /// الكتب الأكثر استعارة (الأعلى أولاً).
  List<MapEntry<Book, int>> topBooks({int limit = 5}) {
    final list = <MapEntry<Book, int>>[
      for (final b in _books) MapEntry(b, _borrowCounts[b.id] ?? 0),
    ];
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }

  /// هل للمستخدم نشاط (استعارات أو مفضلة)؟ لتحديد نوع الاقتراحات.
  bool hasActivity(String username) =>
      _loans.any((l) => l.username == username) ||
      (_favorites[username]?.isNotEmpty ?? false);

  /// اقتراحات المكتبة الذكية: من الأقسام التي يهتم بها المستخدم،
  /// أو الأكثر استعارة إن كان مستخدماً جديداً.
  List<Book> suggestionsFor(String username, {int limit = 8}) {
    if (!hasActivity(username)) {
      return topBooks(limit: limit).map((e) => e.key).toList();
    }
    final favIds = _favSet(username);
    final mine = _loans.where((l) => l.username == username).toList();
    final liked = <int>{};
    for (final id in favIds) {
      final b = bookById(id);
      if (b != null) liked.add(b.categoryId);
    }
    for (final l in mine) {
      final b = bookById(l.bookId);
      if (b != null) liked.add(b.categoryId);
    }
    final owned = <int>{
      ...favIds,
      ...mine.where((l) => l.isActive).map((l) => l.bookId),
    };
    final candidates =
        _books.where((b) => !owned.contains(b.id) && b.isAvailable).toList();
    candidates.sort((a, b) {
      final sa = liked.contains(a.categoryId) ? 1 : 0;
      final sb = liked.contains(b.categoryId) ? 1 : 0;
      if (sa != sb) return sb - sa;
      return (_borrowCounts[b.id] ?? 0) - (_borrowCounts[a.id] ?? 0);
    });
    return candidates.take(limit).toList();
  }

  /// عدد الاستعارات في آخر 6 أشهر (الأشهر السابقة قيم تجريبية، والحالي حقيقي).
  List<MapEntry<String, int>> monthlyLoans() {
    const seeds = [18, 24, 19, 31, 27];
    final now = DateTime.now();
    final result = <MapEntry<String, int>>[];
    for (var i = 5; i >= 1; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      result.add(MapEntry(arabicMonthName(d.month), seeds[5 - i]));
    }
    final thisMonth = _loans
        .where((l) =>
            l.borrowedAt.year == now.year && l.borrowedAt.month == now.month)
        .length;
    result.add(MapEntry(arabicMonthName(now.month), thisMonth));
    return result;
  }

  /// يسجل أن المدير أنشأ تقريراً (التصدير الفعلي لملف يأتي مع الربط بالخادم).
  void logExport(String format) {
    _requireAdmin();
    _log('إنشاء تقرير $format');
    notifyListeners();
  }

  // ───────────────────────── أدوات داخلية ─────────────────────────

  Book _mustBook(int id) {
    final b = bookById(id);
    if (b == null) throw const LibraryException('الكتاب غير موجود');
    return b;
  }

  Loan _mustLoan(int id) {
    for (final l in _loans) {
      if (l.id == id) return l;
    }
    throw const LibraryException('الاستعارة غير موجودة');
  }

  void _log(String message) {
    _logs.insert(
      0,
      LogEntry(
        message: message,
        username: _current?.username ?? 'system',
        at: DateTime.now(),
      ),
    );
  }

  // ───────────────────────── بيانات تجريبية ─────────────────────────

  void _seed() {
    final now = DateTime.now();

    _users.addAll([
      AppUser(
        username: 'user1',
        fullName: 'طارق',
        role: UserRole.user,
        password: tempPassword,
        lastLogin: now.subtract(const Duration(days: 1)),
      ),
      AppUser(
          username: 'user2',
          fullName: 'خالد',
          role: UserRole.user,
          password: tempPassword),
      AppUser(
          username: 'lib1',
          fullName: 'سالم',
          role: UserRole.librarian,
          password: tempPassword),
      AppUser(
          username: 'admin',
          fullName: 'مدير النظام',
          role: UserRole.admin,
          password: tempPassword),
    ]);

    _categories.addAll([
      BookCategory(id: 1, name: 'القانون', iconKey: 'scale'),
      BookCategory(id: 2, name: 'الإدارة', iconKey: 'work'),
      BookCategory(id: 3, name: 'المحاسبة', iconKey: 'calc'),
      BookCategory(id: 4, name: 'الحاسوب', iconKey: 'computer'),
    ]);

    Book b(int id, String t, String a, int c, bool d, int total, int avail) =>
        Book(
          id: id,
          title: t,
          author: a,
          categoryId: c,
          isDigital: d,
          totalCopies: total,
          availableCopies: avail,
          publishDate: DateTime(2012 + id % 10, 1 + id % 9, 15),
          fileName: d ? '$t.pdf' : null,
        );

    _books.addAll([
      b(1, 'القانون الإداري الليبي', 'د. محمد السنوسي', 1, false, 3, 2),
      b(2, 'الوجيز في القانون الإداري', 'د. سليمان الطماوي', 1, false, 1, 0),
      b(3, 'مكافحة الفساد الإداري', 'د. عادل الورفلي', 1, true, 2, 2),
      b(4, 'الحوكمة والشفافية', 'د. منى الفيتوري', 2, false, 2, 2),
      b(5, 'إدارة الموارد البشرية', 'د. علي بوزيد', 2, true, 1, 1),
      b(6, 'التخطيط الاستراتيجي', 'أ. حسن المبروك', 2, false, 2, 2),
      b(7, 'أصول المحاسبة الحكومية', 'أ. فاطمة الزروق', 3, false, 2, 2),
      b(8, 'الرقابة المالية والمراجعة', 'د. نورية الغرياني', 3, true, 1, 1),
      b(9, 'مبادئ أمن المعلومات', 'م. يوسف الشريف', 4, true, 1, 1),
      b(10, 'قواعد البيانات', 'م. هالة القذافي', 4, false, 2, 2),
    ]);

    _borrowCounts.addAll({1: 12, 3: 9, 4: 7, 7: 6, 9: 5, 6: 4});

    _favorites['user1'] = {1, 3, 4, 5, 9};

    for (final r in const [
      (1, 'user2', 5, 'مرجع ممتاز ومبسط'),
      (1, 'user1', 4, ''),
      (3, 'user2', 5, 'مفيد جداً لموظفي الرقابة'),
      (4, 'user1', 4, 'عرض واضح للحوكمة'),
      (7, 'user2', 3, ''),
      (9, 'user2', 5, 'مناسب للمبتدئين'),
    ]) {
      _ratings.add(Rating(
        id: _nextId++,
        bookId: r.$1,
        username: r.$2,
        stars: r.$3,
        comment: r.$4,
      ));
    }

    _loans.addAll([
      Loan(
        id: 1,
        bookId: 1,
        username: 'user1',
        borrowedAt: now.subtract(const Duration(days: 11)),
        dueAt: now.add(const Duration(days: 3)),
      ),
      Loan(
        id: 2,
        bookId: 2,
        username: 'user2',
        borrowedAt: now.subtract(const Duration(days: 16)),
        dueAt: now.subtract(const Duration(days: 2)),
      ),
      Loan(
        id: 3,
        bookId: 4,
        username: 'user1',
        borrowedAt: now.subtract(const Duration(days: 30)),
        dueAt: now.subtract(const Duration(days: 16)),
        returnedAt: now.subtract(const Duration(days: 21)),
      ),
      Loan(
        id: 4,
        bookId: 6,
        username: 'user1',
        borrowedAt: now.subtract(const Duration(days: 60)),
        dueAt: now.subtract(const Duration(days: 46)),
        returnedAt: now.subtract(const Duration(days: 50)),
      ),
    ]);

    _requests.add(BookRequest(
      id: 5,
      username: 'user2',
      title: 'التحول الرقمي في الإدارة العامة',
      author: 'د. أمل الككلي',
    ));

    _announcements.add(Announcement(
      id: 6,
      text: 'المكتبة مفتوحة من الساعة 8 صباحاً حتى 2 ظهراً طوال أيام العمل',
      date: now.subtract(const Duration(days: 2)),
    ));

    _notifications.add(AppNotification(
      id: 7,
      username: 'user1',
      title: 'أصبح كتاب "مبادئ أمن المعلومات" متاحاً',
      subtitle: 'كان محجوزاً لك',
      createdAt: now.subtract(const Duration(hours: 5)),
    ));

    _logs.addAll([
      LogEntry(
          message: 'إضافة قسم: الحاسوب',
          username: 'admin',
          at: now.subtract(const Duration(days: 3))),
      LogEntry(
          message: 'إضافة كتاب: مبادئ أمن المعلومات',
          username: 'lib1',
          at: now.subtract(const Duration(days: 2))),
    ]);
  }
}
