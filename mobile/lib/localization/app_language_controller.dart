import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'app_language.dart';

class AppLanguageController extends ChangeNotifier {
  AppLanguage _language = AppLanguage.japanese;
  bool _loaded = false;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;
  bool get loaded => _loaded;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(
      preferences.getString(languageStorageKey),
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;

    _language = language;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(languageStorageKey, language.code);
  }
}
