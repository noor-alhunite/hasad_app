import '../models/season_model.dart';
import '../providers/season_provider.dart';

/// ترتيب المواسم حسب الأحدث أولاً (لـ UI الرئيسية وقوائم «عرض الكل»).
List<SeasonModel> getFarmerSeasonsOrdered(
  String farmerId,
  SeasonProvider provider,
) {
  final rows = provider.getSeasonsForFarmer(farmerId).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return rows;
}

/// محاكاة جلب من API — استبدل المحتوى بطلب HTTP لاحقاً مع نفس التوقيع تقريباً.
Future<List<SeasonModel>> fetchFarmerSeasonsMock(
  String farmerId,
  SeasonProvider provider,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 150));
  return getFarmerSeasonsOrdered(farmerId, provider);
}
