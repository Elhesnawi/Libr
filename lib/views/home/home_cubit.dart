import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/home/home_state.dart';

class HomeCubit extends Cubit<HomeState>{
  HomeCubit():super (InitHomeState());

}
