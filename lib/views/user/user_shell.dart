import 'package:flutter/material.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/user/home_tab.dart';
import 'package:librarry_app/views/user/loans_tab.dart';
import 'package:librarry_app/views/user/notifications_screen.dart';
import 'package:librarry_app/views/user/profile_view.dart';
import 'package:librarry_app/views/user/search_tab.dart';
import 'package:librarry_app/widgets/common.dart';
import 'package:librarry_app/widgets/library_app_bar.dart';
import 'package:librarry_app/widgets/loading_splash.dart';

/// واجهة المستخدم العادي: خمس تبويبات في الأسفل.
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  static const _titles = ['الرئيسية', 'البحث', 'استعاراتي', 'المفضلة', 'حسابي'];
  int _index = 0;

  Future<void> _select(int i) async {
    if (i == _index) return;
    await withSplash<void>(context, () {}, ms: 250);
    if (!mounted) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final store = LibraryStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser;
        // أثناء تسجيل الخروج قد يعاد البناء قبل إزالة الشاشة.
        if (user == null) return const SizedBox.shrink();

        final unread = store.unreadCount(user.username);
        final Widget body;
        switch (_index) {
          case 0:
            body = HomeTab(user: user, onSwitchTab: _select);
            break;
          case 1:
            body = const SearchTab();
            break;
          case 2:
            body = const LoansTab();
            break;
          case 3:
            body = const FavoritesTab();
            break;
          default:
            body = const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ProfileView(),
            );
        }

        return Scaffold(
          appBar: LibraryAppBar(
            title: _titles[_index],
            actions: [
              IconButton(
                tooltip: 'الإشعارات',
                onPressed: () => openScreen(context, const NotificationsScreen()),
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'استعاراتي'),
              NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'المفضلة'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
            ],
          ),
        );
      },
    );
  }
}
