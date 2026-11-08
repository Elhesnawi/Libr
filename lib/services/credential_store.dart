import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// بيانات الدخول المحفوظة عند اختيار «تذكّر كلمة المرور».
class SavedCredentials {
  const SavedCredentials(this.username, this.password);

  final String username;
  final String password;
}

/// مكان حفظ بيانات الدخول. أي فشل في القراءة أو الكتابة لا يوقف التطبيق.
abstract class CredentialStore {
  Future<SavedCredentials?> read();
  Future<void> save(String username, String password);
  Future<void> clear();
}

/// حفظ مشفّر على الجهاز عبر flutter_secure_storage
/// (Keystore على أندرويد، Keychain على iOS).
class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _userKey = 'remembered_username';
  static const _passKey = 'remembered_password';

  @override
  Future<SavedCredentials?> read() async {
    try {
      final u = await _storage.read(key: _userKey);
      final p = await _storage.read(key: _passKey);
      if (u == null || p == null || u.isEmpty || p.isEmpty) return null;
      return SavedCredentials(u, p);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String username, String password) async {
    try {
      await _storage.write(key: _userKey, value: username);
      await _storage.write(key: _passKey, value: password);
    } catch (_) {
      // الحفظ ميزة إضافية: نتجاهل الفشل ولا نمنع تسجيل الدخول.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _passKey);
    } catch (_) {}
  }
}

/// نسخة في الذاكرة للاختبارات.
class MemoryCredentialStore implements CredentialStore {
  SavedCredentials? _saved;

  @override
  Future<SavedCredentials?> read() async => _saved;

  @override
  Future<void> save(String username, String password) async =>
      _saved = SavedCredentials(username, password);

  @override
  Future<void> clear() async => _saved = null;
}
