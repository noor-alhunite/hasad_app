import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/models/season_model.dart';

/// درجة نضج المحصول على الخريطة (ألوان الإطار).
enum FarmerLandMaturity {
  ripe,
  halfRipe,
  unripe,
}

/// قطعة أرض وهمية للمزارع الحالي.
class FarmerParcelMock {
  final String id;
  final String seasonId;
  final String landLabel;
  final double latitude;
  final double longitude;
  final String cropName;
  final FarmerLandMaturity maturity;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final double areaDunum;
  final double expectedProductionTons;

  const FarmerParcelMock({
    required this.id,
    required this.seasonId,
    required this.landLabel,
    required this.latitude,
    required this.longitude,
    required this.cropName,
    required this.maturity,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.areaDunum,
    required this.expectedProductionTons,
  });
}

/// عرض سوق وهمي — مزارعون آخرون (طبقة السوق).
class FarmerMarketOfferMock {
  final String id;
  final String farmerName;
  final String cropName;
  final double pricePerKgJd;
  final double quantityKg;
  final FarmerLandMaturity maturity;
  final double latitude;
  final double longitude;

  const FarmerMarketOfferMock({
    required this.id,
    required this.farmerName,
    required this.cropName,
    required this.pricePerKgJd,
    required this.quantityKg,
    required this.maturity,
    required this.latitude,
    required this.longitude,
  });
}

/// 2–3 أراضٍ للمزارع التجريبي (عمان والجوار).
final List<FarmerParcelMock> kMockFarmerParcels = [
  FarmerParcelMock(
    id: 'p1',
    seasonId: 'mock_season_1',
    landLabel: 'أرض الشمال — حوض 1',
    latitude: 31.962,
    longitude: 35.905,
    cropName: 'طماطم',
    maturity: FarmerLandMaturity.ripe,
    plantingDate: DateTime(2025, 11, 10),
    expectedHarvestDate: DateTime(2026, 4, 20),
    areaDunum: 12,
    expectedProductionTons: 18,
  ),
  FarmerParcelMock(
    id: 'p2',
    seasonId: 'mock_season_2',
    landLabel: 'أرض الوادي — حوض 2',
    latitude: 31.948,
    longitude: 35.918,
    cropName: 'خيار',
    maturity: FarmerLandMaturity.halfRipe,
    plantingDate: DateTime(2026, 1, 5),
    expectedHarvestDate: DateTime(2026, 5, 1),
    areaDunum: 8,
    expectedProductionTons: 10,
  ),
  FarmerParcelMock(
    id: 'p3',
    seasonId: 'mock_season_3',
    landLabel: 'البيت المحمي',
    latitude: 31.955,
    longitude: 35.892,
    cropName: 'فلفل',
    maturity: FarmerLandMaturity.unripe,
    plantingDate: DateTime(2026, 2, 1),
    expectedHarvestDate: DateTime(2026, 6, 10),
    areaDunum: 5,
    expectedProductionTons: 4,
  ),
];

/// 5 عروض من مزارعين آخرين (محافظات مختلفة تقريباً).
final List<FarmerMarketOfferMock> kMockMarketForFarmer = [
  FarmerMarketOfferMock(
    id: 'm1',
    farmerName: 'سالم الخطيب',
    cropName: 'طماطم',
    pricePerKgJd: 4.2,
    quantityKg: 600,
    maturity: FarmerLandMaturity.ripe,
    latitude: 32.55,
    longitude: 35.85,
  ),
  FarmerMarketOfferMock(
    id: 'm2',
    farmerName: 'نادر أبو سالم',
    cropName: 'باذنجان',
    pricePerKgJd: 3.5,
    quantityKg: 400,
    maturity: FarmerLandMaturity.halfRipe,
    latitude: 32.08,
    longitude: 36.09,
  ),
  FarmerMarketOfferMock(
    id: 'm3',
    farmerName: 'هيثم المفرقي',
    cropName: 'خيار',
    pricePerKgJd: 2.9,
    quantityKg: 1200,
    maturity: FarmerLandMaturity.ripe,
    latitude: 32.29,
    longitude: 35.55,
  ),
  FarmerMarketOfferMock(
    id: 'm4',
    farmerName: 'وليد الكركي',
    cropName: 'بطاطس',
    pricePerKgJd: 1.15,
    quantityKg: 3000,
    maturity: FarmerLandMaturity.unripe,
    latitude: 31.19,
    longitude: 35.71,
  ),
  FarmerMarketOfferMock(
    id: 'm5',
    farmerName: 'رامي العجلوني',
    cropName: 'فلفل',
    pricePerKgJd: 5.1,
    quantityKg: 250,
    maturity: FarmerLandMaturity.halfRipe,
    latitude: 32.33,
    longitude: 35.75,
  ),
];

SeasonModel seasonModelFromParcel(FarmerParcelMock p) {
  return SeasonModel(
    id: p.seasonId,
    farmerId: 'current_farmer',
    cropType: p.cropName,
    cropVariety: 'بلدي',
    area: p.areaDunum,
    areaUnit: 'دونم',
    plantingDate: p.plantingDate,
    expectedHarvestDate: p.expectedHarvestDate,
    expectedProduction: p.expectedProductionTons,
    productionUnit: 'طن',
    expectedQuality: 'good',
    fertilizersUsed: const [],
    pesticidesUsed: const [],
    imageUrls: const [],
    location: p.landLabel,
    latitude: p.latitude,
    longitude: p.longitude,
    status: SeasonStatus.active,
    createdAt: p.plantingDate,
  );
}

/// لون إطار النضج (مطابق لمتطلبات الواجهة).
int maturityColorArgb(FarmerLandMaturity m) {
  switch (m) {
    case FarmerLandMaturity.ripe:
      return 0xFF4CAF50;
    case FarmerLandMaturity.halfRipe:
      return 0xFFFFC107;
    case FarmerLandMaturity.unripe:
      return 0xFF795548;
  }
}

String maturityLabelAr(FarmerLandMaturity m) {
  switch (m) {
    case FarmerLandMaturity.ripe:
      return 'ناضج وجاهز للحصاد';
    case FarmerLandMaturity.halfRipe:
      return 'نصف ناضج';
    case FarmerLandMaturity.unripe:
      return 'غير ناضج / جديد';
  }
}

LatLng latLngFromParcel(FarmerParcelMock p) => LatLng(p.latitude, p.longitude);

LatLng latLngFromOffer(FarmerMarketOfferMock o) => LatLng(o.latitude, o.longitude);
