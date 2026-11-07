import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:librarry_app/core/brand.dart';
import 'package:librarry_app/services/library_store.dart';
import 'package:librarry_app/views/auth/auth_cubit.dart';
import 'package:librarry_app/views/login/login_cubit.dart';
import 'package:librarry_app/views/login/login_state.dart';
import 'package:librarry_app/widgets/app_logo.dart';
import 'package:librarry_app/widgets/gold_button.dart';
import 'package:librarry_app/widgets/gold_frame.dart';
import 'package:librarry_app/widgets/loading_splash.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(context.read<AuthCubit>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // إن كان المستخدم اختار «تذكّر كلمة المرور» سابقاً تُملأ الحقول تلقائياً.
    context.read<LoginCubit>().loadSaved().then((saved) {
      if (saved != null && mounted) {
        _username.text = saved.username;
        _password.text = saved.password;
      }
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final cubit = context.read<LoginCubit>();
    await withSplash<void>(
      context,
      () => cubit.submit(_username.text, _password.text),
      ms: 900,
    );
  }

  void _fillDemo(String username) {
    _username.text = username;
    _password.text = LibraryStore.tempPassword;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: const AppLogo(height: 80),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'المكتبة الذكية',
                      textAlign: TextAlign.center,
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سجّل الدخول للمتابعة',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    GoldFrame(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _username,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'اسم المستخدم',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            obscureText: state.obscure,
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(state.obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: context.read<LoginCubit>().toggleObscure,
                              ),
                            ),
                          ),
                          CheckboxListTile(
                            value: state.remember,
                            onChanged: (v) => context.read<LoginCubit>().setRemember(v ?? false),
                            title: const Text('تذكّر كلمة المرور'),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            dense: true,
                            activeColor: Brand.gold,
                            checkColor: Brand.onGold,
                            side: const BorderSide(color: Brand.gold, width: 2),
                          ),
                          if (state.error != null) ...[
                            const SizedBox(height: 4),
                            Text(state.error!, style: TextStyle(color: scheme.error)),
                          ],
                          const SizedBox(height: 10),
                          GoldButton(label: 'دخول', onPressed: _submit),
                        ],
                      ),
                    ),
                    // حسابات التجربة تظهر في وضع التطوير فقط، وتختفي في النسخة النهائية.
                    if (kDebugMode) ...[
                      const SizedBox(height: 20),
                      Text(
                        'حسابات تجريبية (كلمة المرور ${LibraryStore.tempPassword})',
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          ActionChip(label: const Text('مستخدم عادي'), onPressed: () => _fillDemo('user1')),
                          ActionChip(label: const Text('موظف'), onPressed: () => _fillDemo('lib1')),
                          ActionChip(label: const Text('مدير'), onPressed: () => _fillDemo('admin')),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
