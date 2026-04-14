import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }
}
