/// إعدادات الاتصال بمشروع Supabase.
///
/// المفتاح هنا هو الـ Publishable key فقط (يبدأ بـ sb_publishable_)،
/// وهو آمن للنشر بشرط تفعيل RLS على كل الجداول.
/// لا تضع هنا أبداً أي مفتاح يبدأ بـ sb_secret_.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://efqiwppcfxjozwindkbf.supabase.co';

  // الصق الـ Publishable key من: Project Settings → API Keys
  static const String publishableKey = 'PASTE_PUBLISHABLE_KEY_HERE';
}
