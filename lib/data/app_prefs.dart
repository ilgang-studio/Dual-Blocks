import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/localization/game_localization.dart';
import '../game/models/ui/block_theme_mode.dart';

class AppPrefsState {
  const AppPrefsState({
    required this.bestScore,
    required this.themeMode,
    required this.customThemeColor,
    required this.language,
    required this.tutorialCompleted,
  });

  final int bestScore;
  final BlockThemeMode themeMode;
  final Color customThemeColor;
  final String language;
  final bool tutorialCompleted;
}

class AppPrefs {
  static const _bestScoreKey = 'best_score';
  static const _themeModeKey = 'theme_mode';
  static const _customColorKey = 'custom_theme_color';
  static const _languageKey = 'language';
  static const _tutorialCompletedKey = 'tutorial_completed';

  static Future<AppPrefsState> load() async {
    final prefs = await SharedPreferences.getInstance();

    final bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    final modeIndex = prefs.getInt(_themeModeKey) ?? BlockThemeMode.solid.index;
    final safeModeIndex = modeIndex.clamp(0, BlockThemeMode.values.length - 1);
    final customColor = Color(
      prefs.getInt(_customColorKey) ?? const Color(0xFFF59E0B).toARGB32(),
    );
    final language = prefs.getString(_languageKey) ?? GameLocalization.english;
    final safeLanguage = GameLocalization.supportedLanguages.contains(language)
        ? language
        : GameLocalization.english;
    final tutorialCompleted = prefs.getBool(_tutorialCompletedKey) ?? false;

    return AppPrefsState(
      bestScore: bestScore,
      themeMode: BlockThemeMode.values[safeModeIndex],
      customThemeColor: customColor,
      language: safeLanguage,
      tutorialCompleted: tutorialCompleted,
    );
  }

  static Future<void> saveBestScore(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, value);
  }

  static Future<void> saveSettings({
    required BlockThemeMode themeMode,
    required Color customThemeColor,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
    await prefs.setInt(_customColorKey, customThemeColor.toARGB32());
    await prefs.setString(_languageKey, language);
  }

  static Future<void> setTutorialCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, value);
  }
}
