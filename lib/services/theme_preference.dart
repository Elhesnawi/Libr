import 'package:shared_preferences/shared_preferences.dart';

/// حفظ اختيار الوضع الليلي ليبقى بعد إغلاق التطبيق.
/// أي فشل في القراءة أو الكتابة يُتجاهل (يعود المظهر الفاتح الافتراضي).
class ThemePreference {
  ThemePreference._();

  static const _key = 'dark_mode';

  static Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> save(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (_) {}
  }
}
