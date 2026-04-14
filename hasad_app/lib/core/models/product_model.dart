class ProductModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final double farmerRating;
  final String cropType;
  final String cropVariety;
  final double quantity;
  final String unit;
  final double price;
  final String priceUnit;
  final String? imageUrl;
  final String location;
  final double distanceKm;
  final DateTime availableFrom;
  final DateTime availableUntil;
  final String? description;
  final String quality;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerRating,
    required this.cropType,
    required this.cropVariety,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.priceUnit,
    this.imageUrl,
    required this.location,
    required this.distanceKm,
    required this.availableFrom,
    required this.availableUntil,
    this.description,
    required this.quality,
  });

  String get qualityDisplayName {
    switch (quality) {
      case 'premium':
        return 'ممتازة';
      case 'high':
        return 'عالية';
      case 'medium':
        return 'متوسطة';
      default:
        return quality;
    }
  }
}
