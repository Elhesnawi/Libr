import 'package:flutter/material.dart';

/// ألوان الهوية: الأزرق الأساسي للتطبيق، ودرجاته الغامقة للبطاقات الداكنة،
/// والذهبي للمسات الدخول.
class Brand {
  Brand._();

  /// درجات الأزرق الغامق (مشتقة من لون التطبيق الأساسي 0xFF1F5FA6).
  static const Color navyDeep = Color(0xFF0A2447);
  static const Color navy = Color(0xFF123F78);
  static const Color blue = Color(0xFF1F5FA6);

  /// تدرج البطاقات الداكنة (ترحيب المستخدم ولوحة الموظف).
  static const LinearGradient darkCard = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [navyDeep, navy, blue],
    stops: [0, 0.58, 1],
  );

  /// الذهبي.
  static const Color goldDeep = Color(0xFF8A6A1C);
  static const Color gold = Color(0xFFC9992E);
  static const Color goldLight = Color(0xFFF3D27B);
  static const Color goldCream = Color(0xFFFFF6D6);

  /// لون النص فوق الذهبي.
  static const Color onGold = Color(0xFF0A2447);

  /// ألوان الحالة فوق الخلفية الداكنة.
  static const Color okOnDark = Color(0xFF6EE7A8);
  static const Color warnOnDark = goldLight;
  static const Color badOnDark = Color(0xFFFF8A8A);

  /// أبيض بشفافية للعناصر فوق البطاقات الداكنة.
  static Color glass(double alpha) => Colors.white.withValues(alpha: alpha);
}
