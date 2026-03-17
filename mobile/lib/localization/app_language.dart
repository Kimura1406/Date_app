import 'package:flutter/material.dart';

enum AppLanguage {
  vietnamese('vi', 'Việt Nam'),
  japanese('ja', '日本語'),
  korean('ko', '韓国'),
  russian('ru', 'ロシア'),
  chinese('zh', '中国'),
  english('en', '英語'),
  thai('th', 'タイ');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.japanese,
    );
  }
}
