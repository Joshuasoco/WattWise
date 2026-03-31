import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/app_preferences_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._preferencesRepository)
    : super(
        SettingsState(
          currencyCode: _preferencesRepository.currencyCode,
          themeMode: _preferencesRepository.themeMode,
          defaultRatePerKwh: _preferencesRepository.defaultRatePerKwh,
          onboardingCompleted: _preferencesRepository.onboardingCompleted,
        ),
      );

  final AppPreferencesRepository _preferencesRepository;

  Future<void> setCurrencyCode(String currencyCode) async {
    if (currencyCode.trim().isEmpty) return;
    final normalized = currencyCode.trim().toUpperCase();
    await _preferencesRepository.setCurrencyCode(normalized);
    emit(state.copyWith(currencyCode: normalized));
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _preferencesRepository.setThemeMode(themeMode);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setDefaultRatePerKwh(double rate) async {
    final normalized = rate < 0 ? 0.0 : rate;
    await _preferencesRepository.setDefaultRatePerKwh(normalized);
    emit(state.copyWith(defaultRatePerKwh: normalized));
  }

  Future<void> completeOnboarding() async {
    await _preferencesRepository.setOnboardingCompleted(true);
    emit(state.copyWith(onboardingCompleted: true));
  }
}
