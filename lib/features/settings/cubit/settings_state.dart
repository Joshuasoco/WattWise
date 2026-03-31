import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    this.currencyCode = 'PHP',
    this.themeMode = ThemeMode.light,
    this.defaultRatePerKwh = 12,
    this.onboardingCompleted = false,
  });

  final String currencyCode;
  final ThemeMode themeMode;
  final double defaultRatePerKwh;
  final bool onboardingCompleted;

  SettingsState copyWith({
    String? currencyCode,
    ThemeMode? themeMode,
    double? defaultRatePerKwh,
    bool? onboardingCompleted,
  }) {
    return SettingsState(
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      defaultRatePerKwh: defaultRatePerKwh ?? this.defaultRatePerKwh,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
