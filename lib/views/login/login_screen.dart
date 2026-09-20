
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/login/login_cubit.dart';
import 'package:librarry_app/views/login/login_state.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(),
      body: BlocConsumer<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state is LoadingLoginState) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 50,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                const Text('هيئة الرقابة الادارية',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text('نظام المكتبة الذكية',
                  style:TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  )
                ),
                SizedBox(height: 16,),
                TextFormField(
                  controller: usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المستخدم';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'اسم المستخدم',
                    border:OutlineInputBorder()
                    )
                  ),
                  SizedBox(height: 16,),
                TextFormField(
                  controller: passwordController,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال  كلمة المرور';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'كلمة المرور',
                    border:OutlineInputBorder()
                    )
                  ),
                  SizedBox(height: 16,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                     onPressed:(){
                      if(_formKey.currentState!.validate()){
                         context.read<LoginCubit>().login(
                          usernameController.text,
                          passwordController.text
                         );
                      }
                    },
                    child: Text('تسجيل الدخول')
                  ),
                )
              ],
            ),
          ),
          );
      },
      listener: (context, state) {
        if (state is ErrorLoginState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
        }
        if(state is SuccessLoginState){
          //
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('success'))
          );
            //
        }
      },
    ),
    );
  }
}
