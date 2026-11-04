/// توحيد النص العربي للبحث: يتجاهل التشكيل والتطويل والفروق بين الهمزات.
String normalizeArabic(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    // التشكيل (064B-065F) والتطويل (0640) وألف خنجرية (0670).
    if ((rune >= 0x064B && rune <= 0x065F) || rune == 0x0640 || rune == 0x0670) {
      continue;
    }
    switch (rune) {
      case 0x0623: // أ
      case 0x0625: // إ
      case 0x0622: // آ
        buffer.writeCharCode(0x0627); // ا
        break;
      case 0x0629: // ة
        buffer.writeCharCode(0x0647); // ه
        break;
      case 0x0649: // ى
        buffer.writeCharCode(0x064A); // ي
        break;
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString().trim().toLowerCase();
}

const List<String> _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

String arabicMonthName(int month) => _arabicMonths[month - 1];

/// مثال: 3 نوفمبر 2026
String arabicDate(DateTime d) => '${d.day} ${_arabicMonths[d.month - 1]} ${d.year}';

/// مثال: 9:42 ص
String arabicTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour < 12 ? 'ص' : 'م'}';
}

/// مثال: اليوم، 9:42 ص  /  أمس، 9:42 ص  /  1 نوفمبر 2026
String arabicDayAndTime(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'اليوم، ${arabicTime(d)}';
  if (diff == 1) return 'أمس، ${arabicTime(d)}';
  return arabicDate(d);
}

/// تحية حسب الوقت.
String greetingFor(DateTime now) =>
    (now.hour >= 5 && now.hour < 12) ? 'صباح الخير' : 'مساء الخير';

/// نص موعد الإرجاع من عدد الأيام المتبقية.
String dueText(int daysLeft) {
  if (daysLeft < 0) return 'متأخر ${-daysLeft} يوم';
  if (daysLeft == 0) return 'اليوم';
  return 'بعد $daysLeft يوم';
}
