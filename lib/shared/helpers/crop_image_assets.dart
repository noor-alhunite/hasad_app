/// مسارات صور المحاصيل في `assets/images/` وربطها بأسماء عربية/إنجليزية.

/// يعيد مسار الأصل المناسب لنوع المحصول، أو [defaultAsset] إن لم يُعرف.
String resolveCropImageAsset(String cropType, {String defaultAsset = 'assets/images/crop_default.png'}) {
  final raw = cropType.trim();
  if (raw.isEmpty) return defaultAsset;

  final n = raw.toLowerCase();

  bool ar(String a) => raw.contains(a) || n.contains(a);

  if (ar('طماطم') || n.contains('tomato')) return 'assets/images/tomato.png';
  if (ar('خيار') || n.contains('cucumber')) return 'assets/images/cucumber.png';
  if (ar('بطيخ') || n.contains('watermelon')) return 'assets/images/watermelon.png';
  // خس — وأي وصف يشير إلى «أخضر» مع خس (بما فيها أخطاء إملائية شائعة مثل «مفلس»)
  if (ar('خس') ||
      ar('فلفل أخضر') ||
      ar('مفلس أخضر') ||
      n.contains('lettuce') ||
      (n.contains('green') && n.contains('pepper'))) {
    return 'assets/images/lettuce.png';
  }
  if (ar('شمام') || ar('رقي') || n.contains('melon')) return 'assets/images/melon.png';
  // فلفل حار/ألوان (بدون «أخضر» فقط — الفلفل الأخضر يُعرَض كخس أعلاه)
  if ((ar('فلفل') && !ar('أخضر')) || (n.contains('pepper') && !n.contains('green'))) {
    return 'assets/images/pepper.png';
  }
  if (ar('باذنجان') || n.contains('eggplant')) return 'assets/images/eggplant.png';
  if (ar('كوسة') || n.contains('zucchini')) return 'assets/images/zucchini.png';
  if (ar('بطاطس') || n.contains('potato')) return 'assets/images/potato.png';
  if (ar('بصل') || n.contains('onion')) return 'assets/images/onion.png';
  if (ar('تمر') ||
      ar('تمور') ||
      n.contains('dates') ||
      n.contains('date')) {
    return 'assets/images/dates.png';
  }
  if (ar('عنب') || n.contains('grape')) return 'assets/images/grape.png';
  if (ar('قمح') || n.contains('wheat')) return 'assets/images/default_crop.png';
  if (ar('شعير') || n.contains('barley')) return 'assets/images/default_crop.png';

  return defaultAsset;
}
