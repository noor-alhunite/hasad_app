import 'package:flutter/material.dart';
import '../models/product_model.dart';

enum ProductSortOrder { none, priceAsc, priceDesc, distanceAsc }

class ProductProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  ProductSortOrder _sortOrder = ProductSortOrder.none;
  String? _qualityFilter;
  String? _regionFilter;

  final List<ProductModel> _products = [
    ProductModel(
      id: 'p1',
      farmerId: 'farmer_001',
      farmerName: 'محمد العتيبي',
      farmerRating: 4.8,
      cropType: 'طماطم',
      cropVariety: 'طماطم شيري',
      quantity: 500,
      unit: 'كجم',
      price: 4.5,
      priceUnit: 'ر.س/كجم',
      location: 'الرياض',
      distanceKm: 15,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 30)),
      quality: 'high',
    ),
    ProductModel(
      id: 'p2',
      farmerId: 'farmer_002',
      farmerName: 'أحمد الشمري',
      farmerRating: 4.5,
      cropType: 'خيار',
      cropVariety: 'خيار بلدي',
      quantity: 300,
      unit: 'كجم',
      price: 3.0,
      priceUnit: 'ر.س/كجم',
      location: 'الرياض',
      distanceKm: 8,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 20)),
      quality: 'medium',
    ),
    ProductModel(
      id: 'p3',
      farmerId: 'farmer_003',
      farmerName: 'سعد القحطاني',
      farmerRating: 4.9,
      cropType: 'بطيخ',
      cropVariety: 'بطيخ أحمر',
      quantity: 1000,
      unit: 'كجم',
      price: 2.5,
      priceUnit: 'ر.س/كجم',
      location: 'الرياض',
      distanceKm: 25,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 15)),
      quality: 'high',
    ),
    ProductModel(
      id: 'p4',
      farmerId: 'farmer_004',
      farmerName: 'عبدالله المطيري',
      farmerRating: 4.7,
      cropType: 'فلفل أخضر',
      cropVariety: 'فلفل حلو',
      quantity: 200,
      unit: 'كجم',
      price: 5.0,
      priceUnit: 'ر.س/كجم',
      location: 'الرياض',
      distanceKm: 12,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 25)),
      quality: 'premium',
    ),
    ProductModel(
      id: 'p5',
      farmerId: 'farmer_005',
      farmerName: 'فهد السبيعي',
      farmerRating: 4.6,
      cropType: 'تمور',
      cropVariety: 'تمر سكري',
      quantity: 800,
      unit: 'كجم',
      price: 25.0,
      priceUnit: 'ر.س/كجم',
      location: 'الأحساء',
      distanceKm: 380,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 60)),
      quality: 'premium',
    ),
    ProductModel(
      id: 'p6',
      farmerId: 'farmer_006',
      farmerName: 'خالد العمري',
      farmerRating: 4.3,
      cropType: 'باذنجان',
      cropVariety: 'باذنجان بلدي',
      quantity: 250,
      unit: 'كجم',
      price: 3.5,
      priceUnit: 'ر.س/كجم',
      location: 'المدينة المنورة',
      distanceKm: 450,
      availableFrom: DateTime.now(),
      availableUntil: DateTime.now().add(const Duration(days: 10)),
      quality: 'medium',
    ),
  ];

  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  ProductSortOrder get sortOrder => _sortOrder;
  String? get qualityFilter => _qualityFilter;
  String? get regionFilter => _regionFilter;

  List<String> get availableRegions {
    final r = _products.map((p) => p.location).toSet().toList()..sort();
    return r;
  }

  static const List<String> qualityFilterOptions = [
    '',
    'premium',
    'high',
    'medium',
  ];

  List<ProductModel> get filteredProducts {
    List<ProductModel> result = List<ProductModel>.from(_products);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.trim();
      result = result
          .where((p) =>
              p.cropType.contains(q) ||
              p.farmerName.contains(q) ||
              p.cropVariety.contains(q))
          .toList();
    }

    if (_selectedFilter != 'الكل') {
      result = result.where((p) => p.cropType == _selectedFilter).toList();
    }

    if (_regionFilter != null && _regionFilter!.isNotEmpty) {
      result = result.where((p) => p.location.contains(_regionFilter!)).toList();
    }

    if (_qualityFilter != null && _qualityFilter!.isNotEmpty) {
      result = result.where((p) => p.quality == _qualityFilter).toList();
    }

    switch (_sortOrder) {
      case ProductSortOrder.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOrder.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOrder.distanceAsc:
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case ProductSortOrder.none:
        break;
    }

    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSortOrder(ProductSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setQualityFilter(String? quality) {
    _qualityFilter = (quality == null || quality.isEmpty) ? null : quality;
    notifyListeners();
  }

  void setRegionFilter(String? region) {
    _regionFilter = (region == null || region.isEmpty) ? null : region;
    notifyListeners();
  }

  void clearAdvancedFilters() {
    _sortOrder = ProductSortOrder.none;
    _qualityFilter = null;
    _regionFilter = null;
    notifyListeners();
  }

  List<String> get availableFilters {
    final types = _products.map((p) => p.cropType).toSet().toList();
    return ['الكل', ...types];
  }
}
