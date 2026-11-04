import 'dart:typed_data';

import 'package:flutter/material.dart';

/// خطأ مفهوم للمستخدم (رسالته عربية جاهزة للعرض).
class LibraryException implements Exception {
  const LibraryException(this.message);
  final String message;

  @override
  String toString() => message;
}

enum UserRole { user, librarian, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.user:
        return 'مستخدم عادي';
      case UserRole.librarian:
        return 'موظف - أمين مكتبة';
      case UserRole.admin:
        return 'مدير النظام';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.user:
        return 'مستخدم';
      case UserRole.librarian:
        return 'موظف';
      case UserRole.admin:
        return 'مدير';
    }
  }

  bool get isStaff => this != UserRole.user;
}

class AppUser {
  AppUser({
    required this.username,
    required this.fullName,
    required this.role,
    required this.password,
    this.lastLogin,
    this.disabled = false,
    this.disabledReason = '',
    this.disabledAt,
  });

  final String username;
  String fullName;
  UserRole role;
  String password;
  DateTime? lastLogin;

  /// الحساب المعطّل لا يستطيع الدخول، وتبقى بياناته وسجل استعاراته محفوظة.
  bool disabled;
  String disabledReason;
  DateTime? disabledAt;
}

/// أيقونات الأقسام (نخزّن المفتاح بدل الأيقونة ليسهل حفظه لاحقاً في قاعدة بيانات).
const Map<String, IconData> categoryIcons = {
  'scale': Icons.balance,
  'work': Icons.work_outline,
  'calc': Icons.calculate_outlined,
  'computer': Icons.computer,
  'folder': Icons.folder_outlined,
};

class BookCategory {
  BookCategory({required this.id, required this.name, this.iconKey = 'folder'});

  final int id;
  String name;
  String iconKey;

  IconData get icon => categoryIcons[iconKey] ?? Icons.folder_outlined;
}

class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.isDigital,
    required this.totalCopies,
    required this.availableCopies,
    this.publishDate,
    this.coverBytes,
    this.fileName,
    this.pages = 12,
  });

  final int id;
  String title;
  String author;
  int categoryId;
  bool isDigital;
  int totalCopies;
  int availableCopies;

  /// تاريخ النشر (يدخله أمين المكتبة عند إضافة الكتاب).
  DateTime? publishDate;

  /// صورة الغلاف (بايتات الصورة). لاحقاً تصبح رابطاً في التخزين السحابي.
  Uint8List? coverBytes;

  /// اسم ملف PDF للكتاب الرقمي. لاحقاً يصبح مساراً في التخزين السحابي.
  String? fileName;

  /// عدد صفحات القارئ التجريبي للكتب الرقمية.
  int pages;

  /// الكتاب الرقمي متاح دائماً (يُقرأ ويُحمَّل بلا استعارة).
  bool get isAvailable => isDigital || availableCopies > 0;

  /// رمز الباركود الظاهر على الكتاب الورقي.
  String get code => 'BK-${id.toString().padLeft(4, '0')}';
}

class Rating {
  Rating({
    required this.id,
    required this.bookId,
    required this.username,
    required this.stars,
    this.comment = '',
  });

  final int id;
  final int bookId;
  final String username;
  int stars;
  String comment;
}

class Loan {
  Loan({
    required this.id,
    required this.bookId,
    required this.username,
    required this.borrowedAt,
    required this.dueAt,
    this.returnedAt,
  });

  final int id;
  final int bookId;
  final String username;
  final DateTime borrowedAt;
  DateTime dueAt;
  DateTime? returnedAt;

  bool get isActive => returnedAt == null;

  /// عدد الأيام المتبقية (سالب = متأخر).
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueAt.year, dueAt.month, dueAt.day);
    return due.difference(today).inDays;
  }

  bool get isOverdue => isActive && daysLeft < 0;
}

enum RequestStatus { pending, accepted, rejected }

extension RequestStatusX on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'قيد المراجعة';
      case RequestStatus.accepted:
        return 'مقبول';
      case RequestStatus.rejected:
        return 'مرفوض';
    }
  }
}

class BookRequest {
  BookRequest({
    required this.id,
    required this.username,
    required this.title,
    required this.author,
    this.status = RequestStatus.pending,
  });

  final int id;
  final String username;
  final String title;
  final String author;
  RequestStatus status;
}

class Announcement {
  Announcement({required this.id, required this.text, required this.date});

  final int id;
  final String text;
  final DateTime date;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.username,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.read = false,
  });

  final int id;
  final String username;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  bool read;
}

class LogEntry {
  LogEntry({required this.message, required this.username, required this.at});

  final String message;
  final String username;
  final DateTime at;
}

class LibraryStats {
  const LibraryStats({
    required this.books,
    required this.activeLoans,
    required this.lateLoans,
    required this.users,
    required this.pendingRequests,
  });

  final int books;
  final int activeLoans;
  final int lateLoans;
  final int users;
  final int pendingRequests;
}
