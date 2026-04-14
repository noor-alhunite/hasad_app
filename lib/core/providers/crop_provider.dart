import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class CropProvider extends ChangeNotifier {
  final List<CropModel> _crops = [
    CropModel(
      id: '1',
      name: 'طماطم',
      varieties: ['طماطم شيري', 'طماطم عادي', 'طماطم كرزي'],
      averagePrice: 4.5,
      season: 'ربيع - صيف',
    ),
    CropModel(
      id: '2',
      name: 'خيار',
      varieties: ['خيار بلدي', 'خيار شيك', 'خيار هولندي'],
      averagePrice: 3.0,
      season: 'ربيع - صيف',
    ),
    CropModel(
      id: '3',
      name: 'بطيخ',
      varieties: ['بطيخ أحمر', 'بطيخ أصفر', 'بطيخ صغير'],
      averagePrice: 2.5,
      season: 'صيف',
    ),
    CropModel(
      id: '4',
      name: 'فلفل',
      varieties: ['فلفل حار', 'فلفل حلو', 'فلفل أخضر', 'فلفل أحمر'],
      averagePrice: 5.0,
      season: 'ربيع - خريف',
    ),
    CropModel(
      id: '5',
      name: 'باذنجان',
      varieties: ['باذنجان بلدي', 'باذنجان طويل'],
      averagePrice: 3.5,
      season: 'صيف - خريف',
    ),
    CropModel(
      id: '6',
      name: 'كوسة',
      varieties: ['كوسة خضراء', 'كوسة صفراء'],
      averagePrice: 3.0,
      season: 'ربيع - صيف',
    ),
    CropModel(
      id: '7',
      name: 'بطاطس',
      varieties: ['بطاطس بيضاء', 'بطاطس حمراء'],
      averagePrice: 2.0,
      season: 'شتاء - ربيع',
    ),
    CropModel(
      id: '8',
      name: 'بصل',
      varieties: ['بصل أبيض', 'بصل أحمر'],
      averagePrice: 1.5,
      season: 'شتاء',
    ),
    CropModel(
      id: '9',
      name: 'تمور',
      varieties: ['تمر مجدول', 'تمر سكري', 'تمر خلاص'],
      averagePrice: 25.0,
      season: 'صيف',
    ),
    CropModel(
      id: '10',
      name: 'عنب',
      varieties: ['عنب أخضر', 'عنب أحمر', 'عنب أسود'],
      averagePrice: 8.0,
      season: 'صيف',
    ),
  ];

  List<CropModel> get crops => _crops;

  List<String> get cropNames => _crops.map((c) => c.name).toList();

  List<String> getVarietiesForCrop(String cropName) {
    return _crops
        .firstWhere(
          (crop) => crop.name == cropName,
          orElse: () => CropModel(id: '', name: '', varieties: []),
        )
        .varieties;
  }

  CropModel? getCropByName(String name) {
    try {
      return _crops.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}
