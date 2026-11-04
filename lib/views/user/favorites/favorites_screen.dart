import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/user/favorites/favorites_cubit.dart';
import 'package:librarry_app/views/user/favorites/favorites_state.dart';
import 'package:librarry_app/widgets/book_tile.dart';
import 'package:librarry_app/widgets/common.dart';

/// الكتب المفضلة للمستخدم.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesCubit(),
      child: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.books.isEmpty) {
            return const EmptyState(
              message: 'لم تضف كتباً إلى المفضلة بعد',
              icon: Icons.bookmark_border,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [for (final b in state.books) BookTile(book: b)],
          );
        },
      ),
    );
  }
}
