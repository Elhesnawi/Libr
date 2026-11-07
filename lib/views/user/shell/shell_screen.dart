import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/user/favorites/favorites_screen.dart';
import 'package:librarry_app/views/user/home/home_screen.dart';
import 'package:librarry_app/views/user/loans/loans_screen.dart';
import 'package:librarry_app/views/user/notifications/notifications_screen.dart';
import 'package:librarry_app/views/user/profile/profile_screen.dart';
import 'package:librarry_app/views/user/search/search_screen.dart';
import 'package:librarry_app/views/user/shell/shell_cubit.dart';
import 'package:librarry_app/views/user/shell/shell_navigation.dart';
import 'package:librarry_app/views/user/shell/shell_state.dart';
import 'package:librarry_app/widgets/account_menu.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';

/// واجهة المستخدم العادي: خمس تبويبات في الأسفل.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: const _ShellView(),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView();

  static const _titles = ['الرئيسية', 'البحث', 'استعاراتي', 'المفضلة', 'بيانات حسابي'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellCubit, ShellState>(
      builder: (context, state) {
        final Widget body;
        switch (state.index) {
          case 0:
            body = const HomeScreen();
            break;
          case 1:
            body = const SearchScreen();
            break;
          case 2:
            body = const LoansScreen();
            break;
          case 3:
            body = const FavoritesScreen();
            break;
          default:
            body = const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ProfileView(),
            );
        }

        return Scaffold(
          appBar: LibraryAppBar(
            title: _titles[state.index],
            actions: [
              IconButton(
                tooltip: 'الإشعارات',
                onPressed: () => openScreen(context, const NotificationsScreen()),
                icon: Badge(
                  isLabelVisible: state.unread > 0,
                  label: Text('${state.unread}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
              AccountMenu(onOpenAccount: () => switchTab(context, 4)),
            ],
          ),
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.index,
            onDestinationSelected: (i) => switchTab(context, i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'استعاراتي'),
              NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'المفضلة'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'بيانات حسابي'),
            ],
          ),
        );
      },
    );
  }
}
