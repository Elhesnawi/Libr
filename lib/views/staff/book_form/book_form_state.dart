import 'dart:typed_data';

import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';

class BookFormState {
  const BookFormState({
    required this.categories,
    required this.categoryId,
    required this.digital,
    required this.publishDate,
    required this.cover,
    required this.fileName,
    this.error,
  });

  final List<BookCategory> categories;
  final int? categoryId;
  final bool digital;
  final DateTime? publishDate;
  final Uint8List? cover;
  final String? fileName;
  final String? error;

  /// قيم أولية من كتاب موجود (تعديل) أو فارغة (إضافة).
  factory BookFormState.initial(LibraryStore s, Book? b) => BookFormState(
        categories: s.categories,
        categoryId: b?.categoryId ?? (s.categories.isEmpty ? null : s.categories.first.id),
        digital: b?.isDigital ?? false,
        publishDate: b?.publishDate,
        cover: b?.coverBytes,
        fileName: b?.fileName,
      );

  BookFormState copyWith({
    int? categoryId,
    bool? digital,
    DateTime? publishDate,
    Uint8List? cover,
    String? fileName,
    String? error,
    bool clearError = false,
  }) =>
      BookFormState(
        categories: categories,
        categoryId: categoryId ?? this.categoryId,
        digital: digital ?? this.digital,
        publishDate: publishDate ?? this.publishDate,
        cover: cover ?? this.cover,
        fileName: fileName ?? this.fileName,
        error: clearError ? null : (error ?? this.error),
      );
}
