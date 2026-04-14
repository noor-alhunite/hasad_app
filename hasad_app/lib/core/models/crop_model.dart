class CropModel {
  final String id;
  final String name;
  final List<String> varieties;
  final String? imageUrl;
  final double? averagePrice;
  final String? season;

  CropModel({
    required this.id,
    required this.name,
    required this.varieties,
    this.imageUrl,
    this.averagePrice,
    this.season,
  });
}
