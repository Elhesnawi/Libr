import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/staff/category_form/category_form_state.dart';

class CategoryFormCubit extends Cubit<CategoryFormState> {
  CategoryFormCubit() : super(const CategoryFormState(iconKey: 'folder'));

  void selectIcon(String key) => emit(CategoryFormState(iconKey: key));

  void save(String name) =>
      LibraryStore.instance.addCategory(name, iconKey: state.iconKey);
}
