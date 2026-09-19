import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isArabic => _locale.languageCode == 'ar';

  void setDarkMode(bool enabled) {
    final nextMode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == nextMode) {
      return;
    }
    _themeMode = nextMode;
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    final nextLocale = Locale(languageCode);
    if (_locale == nextLocale) {
      return;
    }
    _locale = nextLocale;
    notifyListeners();
  }
}
