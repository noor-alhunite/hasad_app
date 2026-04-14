import 'package:flutter/material.dart';
import '../models/season_model.dart';

class SeasonProvider extends ChangeNotifier {
  final List<SeasonModel> _seasons = [
    SeasonModel(
      id: 's1',
      farmerId: 'farmer_001',
      cropType: 'طماطم',
      cropVariety: 'طماطم شيري',
      area: 5,
      areaUnit: 'دونم',
      plantingDate: DateTime(2026, 1, 15),
      expectedHarvestDate: DateTime(2026, 4, 15),
      expectedProduction: 8,
      productionUnit: 'طن',
      expectedQuality: 'excellent',
      fertilizersUsed: ['سماد عضوي', 'NPK'],
      pesticidesUsed: [],
      imageUrls: [],
      location: 'الرياض',
      latitude: 24.7136,
      longitude: 46.6753,
      status: SeasonStatus.active,
      createdAt: DateTime(2026, 1, 15),
    ),
    SeasonModel(
      id: 's2',
      farmerId: 'farmer_001',
      cropType: 'خيار',
      cropVariety: 'خيار بلدي',
      area: 3,
      areaUnit: 'دونم',
      plantingDate: DateTime(2026, 1, 20),
      expectedHarvestDate: DateTime(2026, 4, 20),
      expectedProduction: 4,
      productionUnit: 'طن',
      expectedQuality: 'good',
      fertilizersUsed: ['سماد عضوي'],
      pesticidesUsed: [],
      imageUrls: [],
      location: 'الرياض',
      latitude: 24.7136,
      longitude: 46.6753,
      status: SeasonStatus.inHarvest,
      createdAt: DateTime(2026, 1, 20),
    ),
    SeasonModel(
      id: 's3',
      farmerId: 'farmer_001',
      cropType: 'قمح',
      cropVariety: 'قمح صحروي',
      area: 12,
      areaUnit: 'دونم',
      plantingDate: DateTime(2025, 11, 1),
      expectedHarvestDate: DateTime(2026, 3, 30),
      expectedProduction: 25,
      productionUnit: 'طن',
      expectedQuality: 'very_good',
      fertilizersUsed: ['يوريا', 'سماد مركب'],
      pesticidesUsed: [],
      imageUrls: [],
      location: 'القصيم',
      latitude: 26.3260,
      longitude: 43.9750,
      status: SeasonStatus.harvested,
      createdAt: DateTime(2025, 11, 1),
    ),
  ];

  List<SeasonModel> get seasons => _seasons;

  List<SeasonModel> getSeasonsForFarmer(String farmerId) {
    final owned = _seasons.where((s) => s.farmerId == farmerId).toList();
    if (owned.isNotEmpty) return owned;
    return _mockSeasonsForFarmer(farmerId);
  }

  /// مواسم وهمية لأي مزارع لا تملك سجلات بعد (سند، زائر، حساب جديد…) حتى ربط API.
  List<SeasonModel> _mockSeasonsForFarmer(String farmerId) {
    return [
      SeasonModel(
        id: '${farmerId}_mock_1',
        farmerId: farmerId,
        cropType: 'طماطم',
        cropVariety: 'طماطم شيري',
        area: 4,
        areaUnit: 'دونم',
        plantingDate: DateTime(2026, 1, 10),
        expectedHarvestDate: DateTime(2026, 4, 10),
        expectedProduction: 6,
        productionUnit: 'طن',
        expectedQuality: 'excellent',
        fertilizersUsed: ['سماد عضوي'],
        pesticidesUsed: [],
        imageUrls: [],
        location: 'الرياض',
        latitude: 24.7136,
        longitude: 46.6753,
        status: SeasonStatus.active,
        createdAt: DateTime(2026, 1, 10),
      ),
      SeasonModel(
        id: '${farmerId}_mock_2',
        farmerId: farmerId,
        cropType: 'خيار',
        cropVariety: 'خيار بلدي',
        area: 2.5,
        areaUnit: 'دونم',
        plantingDate: DateTime(2026, 2, 1),
        expectedHarvestDate: DateTime(2026, 5, 1),
        expectedProduction: 3,
        productionUnit: 'طن',
        expectedQuality: 'good',
        fertilizersUsed: [],
        pesticidesUsed: [],
        imageUrls: [],
        location: 'الرياض',
        latitude: 24.7136,
        longitude: 46.6753,
        status: SeasonStatus.active,
        createdAt: DateTime(2026, 2, 1),
      ),
      SeasonModel(
        id: '${farmerId}_mock_3',
        farmerId: farmerId,
        cropType: 'بطيخ',
        cropVariety: 'بطيخ مربى',
        area: 6,
        areaUnit: 'دونم',
        plantingDate: DateTime(2025, 12, 1),
        expectedHarvestDate: DateTime(2026, 3, 1),
        expectedProduction: 12,
        productionUnit: 'طن',
        expectedQuality: 'good',
        fertilizersUsed: ['NPK'],
        pesticidesUsed: [],
        imageUrls: [],
        location: 'القصيم',
        latitude: 26.3260,
        longitude: 43.9750,
        status: SeasonStatus.harvested,
        createdAt: DateTime(2025, 12, 1),
      ),
    ];
  }

  List<SeasonModel> getActiveSeasons(String farmerId) {
    final ownedActive = _seasons
        .where((s) => s.farmerId == farmerId && s.status == SeasonStatus.active)
        .toList();
    if (ownedActive.isNotEmpty) return ownedActive;
    return getSeasonsForFarmer(farmerId)
        .where((s) => s.status == SeasonStatus.active)
        .toList();
  }

  void addSeason(SeasonModel season) {
    _seasons.add(season);
    notifyListeners();
  }

  void updateSeason(SeasonModel season) {
    final index = _seasons.indexWhere((s) => s.id == season.id);
    if (index != -1) {
      _seasons[index] = season;
      notifyListeners();
    }
  }

  void deleteSeason(String id) {
    _seasons.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
