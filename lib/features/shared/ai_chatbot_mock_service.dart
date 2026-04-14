import '../../core/models/user_model.dart';

/// ردود وهمية للمساعد الذكي. لاحقاً: استبدال [getMockReply] بطلب HTTP إلى API (مثل ChatGPT).
class AiChatbotMockService {
  AiChatbotMockService._();

  /// تنسيق التاريخ للترحيب (تاريخ الجهاز).
  static String formatTodayArabic(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  /// توصية موسمية حسب الشهر الحالي.
  static String seasonalTipForMonth(int month) {
    switch (month) {
      case 1:
      case 2:
        return 'الشتاء مناسب للمحاصيل المحمية والخضار الورقية تحت البيوت البلاستيكية في الأغوار.';
      case 3:
        return 'بداية الربيع: جاهّز الأرض للبندورة والخيار والفلفل مع مراقبة الصقيع المتأخر.';
      case 4:
        return 'شهر 4 مناسب لزراعة البندورة، الخيار، والفلفل في الأغوار.';
      case 5:
      case 6:
        return 'ذروة الربيع والصيف المبكر: راقب الري والتغذية، والوقاية من الآفات الحشرية.';
      case 7:
      case 8:
        return 'الصيف: ركز على الري المنتظم والتظليل عند الحاجة، والمحاصيل الحارة مقاومة للجفاف.';
      case 9:
      case 10:
        return 'الخريف: مناسب لزراعة محاصيل قصيرة المدة وتحضير تربة الموسم التالي.';
      case 11:
      case 12:
        return 'الشتاء يقترب: خطط لمحاصيل تتحمل البرودة أو للزراعة المحمية.';
      default:
        return 'راجع تقويمك الزراعي حسب المحصول والمنطقة.';
    }
  }

  static String welcomeMessage(DateTime now) {
    final tip = seasonalTipForMonth(now.month);
    return 'مرحباً! هاليوم ${formatTodayArabic(now)}. التوصيات لهذا الشهر: $tip';
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s\u200f\u200e]+'), ' ').trim();

  /// رد وهمي بعد «إرفاق صورة» من زر المرفقات.
  static String mockImageAnalysisReply() {
    return 'تم تحليل الصورة. التقدير: المحصول يبدو ناضجاً بنسبة 75%';
  }

  /// توليد رد بناءً على الدور والنص. لا يستدعي شبكة.
  static String getMockReply({
    required UserRole role,
    required String userMessage,
    bool messageHadImage = false,
  }) {
    final q = _norm(userMessage);

    // --- مطابقة جمل كاملة تقريبية (المزارع) ---
    if (role == UserRole.farmer) {
      if (_matchesAghwarAprilCrop(q)) {
        return 'في شهر 4، الطماطم والخيار والفلفل من أفضل المحاصيل لمنطقة الأغوار';
      }
      if (q.contains('باذنجان') &&
          (q.contains('ري') || q.contains('موعد') || q.contains('متى'))) {
        return 'الباذنجان يحتاج ري كل 3-4 أيام في الصيف، وكل 5-7 أيام في الشتاء';
      }
      if (q.contains('طماطم') &&
          (q.contains('صفر') || q.contains('صفراء')) &&
          (q.contains('ورق') || q.contains('أوراق'))) {
        return 'قد يكون نقص نيتروجين أو إصابة بفطر. ننصح بعرض الصورة على مهندس زراعي';
      }
    }

    if (role == UserRole.trader) {
      if (q.contains('سعر') &&
          (q.contains('طماطم') || q.contains('بندور')) &&
          (q.contains('أسبوع') || q.contains('هال'))) {
        return 'متوسط سعر الطماطم اليوم: 0.45 دينار/كجم، متوفر بكثرة في الأغوار';
      }
      if (q.contains('خيار') &&
          (q.contains('كمية') || q.contains('كبيرة')) &&
          (q.contains('أين') || q.contains('وين') || q.contains('جد'))) {
        return 'يوجد 3 مزارع في الأغوار لديهم خيار بكميات تتراوح بين 500-1000 كجم';
      }
    }

    if (role == UserRole.factory) {
      if (q.contains('فلفل') &&
          (q.contains('تعاقد') || q.contains('موسم')) &&
          (q.contains('منطقة') || q.contains('أفضل'))) {
        return 'منطقة الأغوار تعتبر الأفضل للفلفل، يزرع من مارس إلى نوفمبر';
      }
      if (q.contains('فلفل') &&
          (q.contains('إنتاج') || q.contains('كم')) &&
          (q.contains('متوقع') || q.contains('موسم') || q.contains('قادم'))) {
        return 'التوقعات تشير إلى إنتاج جيد، بزيادة 15% عن الموسم الماضي';
      }
    }

    // مثال من المواصفات: رفع صورة اختياري (نص) — غير مسار زر 📎
    if (role == UserRole.farmer &&
        q.contains('صورة') &&
        (q.contains('محصول') || q.contains('حقل') || q.contains('ارفع'))) {
      return 'الصورة واضحة، المحصول يبدو في مرحلة نمو جيدة';
    }

    // --- كلمات مفتاحية عامة ---
    if (_hasAny(q, ['أفضل محصول', 'أزرع', 'الأغوار', 'اغوار'])) {
      return 'في منطقة الأغوار تُزرع غالباً الطماطم والخيار والفلفل حسب الموسم؛ شهر 4 مثالي لعدة محاصيل صيفية.';
    }
    if (_hasAny(q, ['سعر', 'أسعار']) &&
        _hasAny(q, ['طماطم', 'بندور', 'خيار'])) {
      return 'أسعار الجملة تقريبية: طماطم حوالي 0.40–0.50 دينار/كجم، خيار 0.35–0.48 حسب العرض والطلب في الأغوار.';
    }
    if (_hasAny(q, ['متى', 'موعد', 'ري']) && _hasAny(q, ['ري', 'سقي'])) {
      return 'جدول الري يعتمد على المحصول والموسم؛ صيفاً غالباً كل 2–4 أيام، شتاءً كل 5–8 أيام مع مراقبة رطوبة التربة.';
    }
    if (_hasAny(q, ['صورة', 'تحليل', 'صور'])) {
      return mockImageAnalysisReply();
    }

    if (messageHadImage) {
      return mockImageAnalysisReply();
    }

    return _defaultByRole(role);
  }

  static bool _matchesAghwarAprilCrop(String q) {
    final hasAghwar = q.contains('اغوار') || q.contains('أغوار');
    final hasMonth4 = q.contains('شهر 4') ||
        q.contains('شهر4') ||
        q.contains(' ن4') ||
        q.contains('4 ') ||
        q.contains('اربعة') ||
        q.contains('أبريل') ||
        q.contains('ابريل');
    final hasCropQ = q.contains('أفضل') ||
        q.contains('محصول') ||
        q.contains('ازرع') ||
        q.contains('أزرع');
    return hasAghwar && hasMonth4 && hasCropQ;
  }

  static bool _hasAny(String q, List<String> keys) {
    for (final k in keys) {
      if (q.contains(_norm(k))) return true;
    }
    return false;
  }

  static String _defaultByRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return 'يمكنني مساعدتك في اختيار المحاصيل، مواعيد الري، ومشاكل الأوراق. جرّب السؤال عن محصول أو منطقة الأغوار.';
      case UserRole.trader:
        return 'اسأل عن أسعار الخضار أو أماكن التوريد بكميات كبيرة، وسأعطيك معلومات تقريبية (وهمية حالياً).';
      case UserRole.factory:
        return 'يمكنني تلخيص مناطق التعاقد على الفلفل والتوقعات، أو الإنتاج المتوقع للموسم (بيانات تجريبية).';
    }
  }
}
