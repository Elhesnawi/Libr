class ShellState {
  const ShellState({this.index = 0, this.unread = 0});

  /// التبويب المحدد: 0 الرئيسية، 1 بحث، 2 استعاراتي، 3 المفضلة، 4 حسابي.
  final int index;

  /// عدد الإشعارات غير المقروءة (شارة الجرس).
  final int unread;
}
