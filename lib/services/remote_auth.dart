import 'package:librarry_app/models/library_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

/// بيانات حساب قادمة من جدول profiles بعد نجاح الدخول.
class RemoteProfile {
  const RemoteProfile({
    required this.username,
    required this.fullName,
    required this.role,
    this.orgKind,
    this.orgValues = const [],
    this.phone = '',
    this.lastLogin,
  });

  final String username;
  final String fullName;
  final UserRole role;
  final OrgKind? orgKind;
  final List<String> orgValues;
  final String phone;
  final DateTime? lastLogin;

  factory RemoteProfile.fromRow(Map<String, dynamic> row) {
    final org = row['org_kind'] as String?;
    return RemoteProfile(
      username: row['username'] as String,
      fullName: (row['full_name'] as String?) ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == row['role'],
        orElse: () => UserRole.user,
      ),
      orgKind: org == null
          ? null
          : OrgKind.values.firstWhere((k) => k.name == org,
              orElse: () => OrgKind.general),
      orgValues: [
        for (final v in (row['org_values'] as List? ?? const [])) '$v',
      ],
      phone: (row['phone'] as String?) ?? '',
      lastLogin: row['last_login'] == null
          ? null
          : DateTime.tryParse('${row['last_login']}')?.toLocal(),
    );
  }
}

/// الدخول والخروج عبر الخادم. يُستبدل في الاختبارات بنسخة وهمية.
abstract class RemoteAuth {
  /// يرمي [LibraryException] برسالة عربية عند الفشل.
  Future<RemoteProfile> signIn(String username, String password);

  Future<void> signOut();
}

/// الدخول عبر Supabase Auth: البريد الداخلي هو username@library.local.
class SupabaseRemoteAuth implements RemoteAuth {
  SupabaseRemoteAuth([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const emailDomain = 'library.local';

  static String emailFor(String username) =>
      '${username.trim().toLowerCase()}@$emailDomain';

  @override
  Future<RemoteProfile> signIn(String username, String password) async {
    final name = username.trim().toLowerCase();
    if (name.isEmpty || password.isEmpty) {
      throw const LibraryException('أدخل اسم المستخدم وكلمة المرور');
    }
    try {
      final res = await _client.auth.signInWithPassword(
        email: emailFor(name),
        password: password,
      );
      final id = res.user?.id;
      if (id == null) {
        throw const LibraryException('تعذّر تسجيل الدخول');
      }

      final row =
          await _client.from('profiles').select().eq('id', id).maybeSingle();
      if (row == null) {
        await _client.auth.signOut();
        throw const LibraryException('لا توجد بيانات لهذا الحساب. راجع مدير النظام');
      }
      if (row['disabled'] == true) {
        await _client.auth.signOut();
        final why = ((row['disabled_reason'] as String?) ?? '').trim();
        throw LibraryException(
          'هذا الحساب معطّل.${why.isEmpty ? '' : ' السبب: $why.'} راجع مدير النظام',
        );
      }

      final profile = RemoteProfile.fromRow(row);
      // نسجّل وقت هذا الدخول. فشل التسجيل لا يمنع الدخول.
      try {
        await _client
            .from('profiles')
            .update({'last_login': DateTime.now().toUtc().toIso8601String()})
            .eq('id', id);
      } catch (_) {}
      return profile;
    } on LibraryException {
      rethrow;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
        throw const LibraryException('اسم المستخدم أو كلمة المرور غير صحيحة');
      }
      if (msg.contains('banned')) {
        throw const LibraryException('هذا الحساب معطّل. راجع مدير النظام');
      }
      if (msg.contains('invalid api key') || msg.contains('apikey')) {
        throw const LibraryException('مفتاح Supabase غير صحيح في ملف الإعدادات');
      }
      throw LibraryException('تعذّر تسجيل الدخول: ${e.message}');
    } catch (_) {
      throw const LibraryException('تعذّر الاتصال بالخادم. تحقق من الإنترنت');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }
}
