import 'package:librarry_app/views/home/home_screen.dart';

abstract class HomeState {}
class InitHomeState extends HomeState {}
class LoadingHomeState extends HomeState {}
class SuccessHomeState extends HomeState {
  final List<CatagoryItem> categories;
SuccessHomeState(this.categories);
}
class ErrorHomeState extends HomeState {
  final String error;
  ErrorHomeState(this.error);
}

