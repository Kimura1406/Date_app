import 'package:flutter/material.dart';

enum AppLanguage {
  vietnamese('vi', 'Việt Nam', '🇻🇳'),
  japanese('ja', '日本語', '🇯🇵'),
  korean('ko', '韓国', '🇰🇷'),
  russian('ru', 'ロシア', '🇷🇺'),
  chinese('zh', '中国', '🇨🇳'),
  english('en', '英語', '🇬🇧'),
  thai('th', 'タイ', '🇹🇭');

  const AppLanguage(this.code, this.label, this.flag);

  final String code;
  final String label;
  final String flag;

  Locale get locale => Locale(code);

  String get displayName => '$flag $label';

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.japanese,
    );
  }
}
