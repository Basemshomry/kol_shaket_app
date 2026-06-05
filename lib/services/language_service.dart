import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();

  LanguageService._internal();

  String _languageCode = 'he';

  String get languageCode => _languageCode;

  bool get isRtl => _languageCode == 'he' || _languageCode == 'ar';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('languageCode') ?? 'he';
    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    _languageCode = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);

    notifyListeners();
  }
}