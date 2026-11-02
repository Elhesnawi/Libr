import 'package:flutter/material.dart';
import 'package:librarry_app/widgets/app_logo.dart';

/// AppBar موحّد لكل الشاشات: الشعار بجانب العنوان.
/// زر الرجوع يظهر تلقائياً في الشاشات الداخلية.
class LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LibraryAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(height: 40),
          const SizedBox(width: 10),
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: actions,
    );
  }
}
