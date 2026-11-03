import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/models/library_models.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/book_form/book_form_state.dart';

/// نموذج إضافة كتاب أو تعديله. حقول النص تبقى في الواجهة (controllers)،
/// وهنا الاختيارات: القسم، النوع، التاريخ، الغلاف، ملف PDF، رسالة الخطأ.
class BookFormCubit extends Cubit<BookFormState> {
  BookFormCubit(this.book) : super(BookFormState.initial(LibraryStore.instance, book));

  /// null عند الإضافة.
  final Book? book;

  void setCategory(int? id) {
    if (id != null) emit(state.copyWith(categoryId: id));
  }

  void setDigital(bool value) => emit(state.copyWith(digital: value));

  void setPublishDate(DateTime date) => emit(state.copyWith(publishDate: date));

  void setCover(Uint8List bytes) => emit(state.copyWith(cover: bytes));

  void setFileName(String name) => emit(state.copyWith(fileName: name));

  void showError(String message) => emit(state.copyWith(error: message));

  void clearError() => emit(state.copyWith(clearError: true));

  /// يرمي [LibraryException] عند فشل التحقق (أو عدم وجود قسم).
  void save({
    required String title,
    required String author,
    required String copiesText,
  }) {
    final catId = state.categoryId;
    if (catId == null) {
      throw const LibraryException('أضف قسماً أولاً');
    }
    final store = LibraryStore.instance;
    final copies = state.digital ? 1 : (int.tryParse(copiesText.trim()) ?? 0);
    final b = book;
    if (b == null) {
      store.addBook(
        title: title,
        author: author,
        categoryId: catId,
        isDigital: state.digital,
        copies: copies,
        publishDate: state.publishDate,
        coverBytes: state.cover,
        fileName: state.fileName,
      );
    } else {
      store.updateBook(
        b.id,
        title: title,
        author: author,
        categoryId: catId,
        isDigital: state.digital,
        copies: copies,
        publishDate: state.publishDate,
        coverBytes: state.cover,
        fileName: state.fileName,
      );
    }
  }
}
