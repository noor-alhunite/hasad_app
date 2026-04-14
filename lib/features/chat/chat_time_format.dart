/// وقت نسبي بالعربية لقائمة المحادثات.
String formatChatTimeAr(DateTime t) {
  final now = DateTime.now();
  final d = now.difference(t);
  if (d.inSeconds < 45) return 'الآن';
  if (d.inMinutes < 60) return 'منذ ${d.inMinutes} دقيقة';
  if (d.inHours < 24) return 'منذ ${d.inHours} ساعة';
  if (d.inDays == 1) return 'الأمس';
  if (d.inDays < 7) return 'منذ ${d.inDays} أيام';
  return '${t.day}/${t.month}';
}

/// تاريخ مختصر لعرض «آخر عرض» (التاجر).
String formatOfferDateShortAr(DateTime? t) {
  if (t == null) return '—';
  return '${t.day}/${t.month}/${t.year}';
}
