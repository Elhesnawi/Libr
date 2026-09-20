import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/services/api_service.dart';
import 'package:librarry_app/views/login/login_cubit.dart';
import 'package:librarry_app/views/login/login_screen.dart';

void main() {
  runApp( MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) 
        => LoginCubit(apiService:ApiService())),

    ],
    child: MaterialApp(home:Directionality(
      textDirection: TextDirection.rtl,
      child: LoginScreen()))
  ));
}
