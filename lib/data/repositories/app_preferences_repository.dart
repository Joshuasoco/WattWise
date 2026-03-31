import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../local/hive_boxes.dart';

class AppPreferencesRepository {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _currencyKey = 'currency_code';
  static const String _themeModeKey = 'theme_mode';
  static const String _defaultRateKey = 'default_rate_per_kwh';

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.appPreferences);

  bool get onboardingCompleted =>
      (_box.get(_onboardingKey, defaultValue: false) as bool?) ?? false;

  String get currencyCode =>
      (_box.get(_currencyKey, defaultValue: 'PHP') as String?) ?? 'PHP';

  ThemeMode get themeMode {
    final raw =
        (_box.get(_themeModeKey, defaultValue: 'light') as String?) ?? 'light';
    return raw == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  double get defaultRatePerKwh {
    final raw = _box.get(_defaultRateKey, defaultValue: 12.0);
    if (raw is num) {
      return raw.toDouble();
    }
    return 12.0;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _box.put(_onboardingKey, completed);
  }

  Future<void> setCurrencyCode(String code) async {
    await _box.put(_currencyKey, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final raw = mode == ThemeMode.dark ? 'dark' : 'light';
    await _box.put(_themeModeKey, raw);
  }

  Future<void> setDefaultRatePerKwh(double rate) async {
    await _box.put(_defaultRateKey, rate);
  }
}
