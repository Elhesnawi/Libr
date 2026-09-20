import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/home/home_cubit.dart';
import 'package:librarry_app/views/home/home_state.dart' show ErrorHomeState, HomeState, LoadingHomeState, SuccessHomeState;


class CatagoryItem {
  final String title;
  final int booksCount;
  final int durationMinutes;
  final IconData icon;

  CatagoryItem({
    required this.title,
    required this.booksCount,
    required this.durationMinutes,
    required this.icon,
  });
}
class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});
final List<CatagoryItem> categories = [
  CatagoryItem(title: 'العلوم المالية والاقتصادية', booksCount: 215, durationMinutes: 4, icon: Icons.show_chart,),
    CatagoryItem(title: 'القانون والدراسات القانونية',
     booksCount: 180,
      durationMinutes: 4, 
      icon: Icons.gavel,),
    CatagoryItem(title: 'الرياضيات والاحصاء',
     booksCount: 130,
      durationMinutes: 3, 
      icon: Icons.functions,),
    CatagoryItem(title: ' العلوم الطبية والصحية',
     booksCount: 165,
      durationMinutes: 3, 
      icon: Icons.add_box_outlined,),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is LoadingHomeState){
            return const Center(child: CircularProgressIndicator(),);
          }
          if (state is ErrorHomeState){
            return  Center(child: Text(state.error),);
          }
          if (state is SuccessHomeState){
            return ListView.builder(itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories[index];
                
                
              }
              )
          }
        },)
    );
  }
}