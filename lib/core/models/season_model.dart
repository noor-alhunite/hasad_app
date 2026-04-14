enum SeasonStatus { active, inHarvest, harvested, cancelled }

class SeasonModel {
  final String id;
  final String farmerId;
  final String cropType;
  final String cropVariety;
  final double area;
  final String areaUnit;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final double expectedProduction;
  final String productionUnit;
  final String expectedQuality;
  final List<String> fertilizersUsed;
  final List<String> pesticidesUsed;
  final List<String> imageUrls;
  final String location;
  final double latitude;
  final double longitude;
  final String? aiAdvice;
  final SeasonStatus status;
  final DateTime createdAt;

  SeasonModel({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.cropVariety,
    required this.area,
    required this.areaUnit,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.expectedProduction,
    required this.productionUnit,
    required this.expectedQuality,
    required this.fertilizersUsed,
    required this.pesticidesUsed,
    required this.imageUrls,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.aiAdvice,
    this.status = SeasonStatus.active,
    required this.createdAt,
  });

  String get statusDisplayName {
    switch (status) {
      case SeasonStatus.active:
        return 'نشط';
      case SeasonStatus.inHarvest:
        return 'قيد الحصاد';
      case SeasonStatus.harvested:
        return 'منتهي';
      case SeasonStatus.cancelled:
        return 'ملغي';
    }
  }

  String get qualityDisplayName {
    switch (expectedQuality) {
      case 'excellent':
        return 'ممتاز';
      case 'very_good':
        return 'جيد جداً';
      case 'good':
        return 'جيد';
      case 'acceptable':
        return 'مقبول';
      default:
        return expectedQuality;
    }
  }
}
