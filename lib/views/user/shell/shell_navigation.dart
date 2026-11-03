import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/views/user/shell/shell_cubit.dart';
import 'package:librarry_app/widgets/loading_splash.dart';

/// ينتقل إلى تبويب في واجهة المستخدم بعد تحميل قصير بشعار الهيئة.
Future<void> switchTab(BuildContext context, int index) async {
  final cubit = context.read<ShellCubit>();
  if (cubit.state.index == index) return;
  await withSplash<void>(context, () {}, ms: 250);
  if (!context.mounted) return;
  cubit.select(index);
}
