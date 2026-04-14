import 'package:google_maps_flutter/google_maps_flutter.dart';

/// سعر التوصيل التقديري: دينار لكل كيلومتر (من عمان).
const double kDeliveryCostPerKm = 0.25;

/// أسماء المنتجات المتاحة للمقارنة.
const List<String> kComparisonCropNames = [
  'طماطم',
  'خيار',
  'فلفل',
  'باذنجان',
];

/// مزارع وهمية في محافظات مختلفة — أسعار ومسافة تقريبية من عمان (يدوياً كما في المواصفات).
class ComparisonFarmer {
  const ComparisonFarmer({
    required this.id,
    required this.name,
    required this.governorateName,
    required this.location,
    required this.distanceKmFromAmman,
    required this.pricePerKgByCrop,
  });

  final String id;
  final String name;
  final String governorateName;
  final LatLng location;

  /// مسافة التوريد التقريبية من عمان (كم) — ثابتة وهمية للجدول التوضيحي.
  final double distanceKmFromAmman;

  /// سعر الكيلو (دينار) لكل محصول.
  final Map<String, double> pricePerKgByCrop;

  double? priceFor(String crop) => pricePerKgByCrop[crop];
}

/// قائمة 5 مزارع — يمكن لاحقاً استبدالها بـ API.
final List<ComparisonFarmer> kComparisonFarmers = [
  ComparisonFarmer(
    id: 'ahmad',
    name: 'أحمد الشمري',
    governorateName: 'عمان',
    location: const LatLng(31.92, 35.91),
    distanceKmFromAmman: 10,
    pricePerKgByCrop: {
      'طماطم': 0.40,
      'خيار': 0.33,
      'فلفل': 0.52,
      'باذنجان': 0.46,
    },
  ),
  ComparisonFarmer(
    id: 'mohammad',
    name: 'محمد العتيبي',
    governorateName: 'إربد',
    location: const LatLng(32.55, 35.85),
    distanceKmFromAmman: 30,
    pricePerKgByCrop: {
      'طماطم': 0.38,
      'خيار': 0.31,
      'فلفل': 0.50,
      'باذنجان': 0.44,
    },
  ),
  ComparisonFarmer(
    id: 'khaled',
    name: 'خالد المومني',
    governorateName: 'الأغوار الشمالية',
    location: const LatLng(32.60, 35.58),
    distanceKmFromAmman: 5,
    pricePerKgByCrop: {
      'طماطم': 0.42,
      'خيار': 0.35,
      'فلفل': 0.54,
      'باذنجان': 0.47,
    },
  ),
  ComparisonFarmer(
    id: 'saad',
    name: 'سعد الكيلاني',
    governorateName: 'الزرقاء',
    location: const LatLng(32.08, 36.09),
    distanceKmFromAmman: 22,
    pricePerKgByCrop: {
      'طماطم': 0.41,
      'خيار': 0.34,
      'فلفل': 0.53,
      'باذنجان': 0.45,
    },
  ),
  ComparisonFarmer(
    id: 'yousef',
    name: 'يوسف الهواري',
    governorateName: 'العقبة',
    location: const LatLng(29.53, 35.00),
    distanceKmFromAmman: 320,
    pricePerKgByCrop: {
      'طماطم': 0.36,
      'خيار': 0.30,
      'فلفل': 0.48,
      'باذنجان': 0.42,
    },
  ),
];

/// صف نتيجة لكل مزارع مختار.
class PriceComparisonRow {
  PriceComparisonRow({
    required this.farmer,
    required this.cropName,
    required this.quantityKg,
    required this.pricePerKg,
    required this.distanceKm,
    required this.productTotal,
    required this.deliveryCost,
    required this.grandTotal,
  });

  final ComparisonFarmer farmer;
  final String cropName;
  final double quantityKg;
  final double pricePerKg;
  final double distanceKm;
  final double productTotal;
  final double deliveryCost;
  final double grandTotal;

  /// حساب الصف من بيانات وهمية ثابتة.
  static PriceComparisonRow compute(
    ComparisonFarmer farmer,
    String crop,
    double quantityKg,
  ) {
    final ppk = farmer.priceFor(crop) ?? 0;
    final dist = farmer.distanceKmFromAmman;
    final product = quantityKg * ppk;
    final delivery = dist * kDeliveryCostPerKm;
    return PriceComparisonRow(
      farmer: farmer,
      cropName: crop,
      quantityKg: quantityKg,
      pricePerKg: ppk,
      distanceKm: dist,
      productTotal: product,
      deliveryCost: delivery,
      grandTotal: product + delivery,
    );
  }
}
