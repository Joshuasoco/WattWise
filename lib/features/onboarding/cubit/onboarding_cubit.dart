import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models/system_spec_model.dart';
import '../../../data/services/system_scan_service.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required Box<dynamic> prefsBox,
    SystemScanService? scanService,
  }) : _prefsBox = prefsBox,
       _scanService = scanService ?? SystemScanService(),
       super(OnboardingState.initial());

  final Box<dynamic> _prefsBox;
  final SystemScanService _scanService;

  void nextStep() {
    if (state.currentStep >= 6) return;
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void previousStep() {
    if (state.currentStep <= 0) return;
    emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  Future<void> startScan() async {
    if (state.isScanning) return;

    final defaults = SystemSpecModel.defaults();
    emit(
      state.copyWith(
        scannedSpecs: defaults,
        isScanning: true,
        clearScanError: true,
        cpuScanned: false,
        gpuScanned: false,
        ramScanned: false,
        storageScanned: false,
        motherboardScanned: false,
      ),
    );
    try {
      final specs = await _scanService.scanSystem(
        onProgress: (progress) {
          if (isClosed) return;
          emit(
            state.copyWith(
              scannedSpecs: progress.specs,
              cpuScanned: progress.cpuScanned,
              gpuScanned: progress.gpuScanned,
              ramScanned: progress.ramScanned,
              storageScanned: progress.storageScanned,
              motherboardScanned: progress.motherboardScanned,
            ),
          );
        },
      );
      emit(
        state.copyWith(
          scannedSpecs: specs,
          confirmedSpecs: specs,
          isScanning: false,
          clearScanError: true,
          cpuScanned: true,
          gpuScanned: true,
          ramScanned: true,
          storageScanned: true,
          motherboardScanned: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isScanning: false,
          scanError: 'Unable to scan your system. Please try again.',
        ),
      );
    }
  }

  void confirmSpecs(SystemSpecModel specs) {
    emit(state.copyWith(confirmedSpecs: specs));
  }

  void setRate(double rate, String symbol) {
    final normalizedRate = rate <= 0 ? 0.01 : rate;
    final normalizedSymbol = symbol.trim().isEmpty ? '₱' : symbol.trim();
    emit(
      state.copyWith(
        electricityRate: normalizedRate,
        currencySymbol: normalizedSymbol,
      ),
    );
  }

  void setHours(double hours) {
    final normalized = hours.clamp(1.0, 24.0).toDouble();
    emit(state.copyWith(dailyHours: normalized));
  }

  void setTermsAccepted(bool accepted) {
    emit(state.copyWith(termsAccepted: accepted));
  }

  Future<void> completeOnboarding() async {
    final specs = state.confirmedSpecs;

    await _prefsBox.put('onboarding_complete', true);
    await _prefsBox.put('cpu_name', specs.cpuName);
    await _prefsBox.put('gpu_type', specs.gpuType);
    await _prefsBox.put('gpu_name', specs.gpuName);
    await _prefsBox.put('ram_gb', specs.ramGb);
    await _prefsBox.put('ram_sticks', specs.ramSticks);
    await _prefsBox.put('storage_count', specs.storageCount);
    await _prefsBox.put('storage_type', specs.storageType);
    await _prefsBox.put('fan_count', specs.fanCount);
    await _prefsBox.put('has_rgb', specs.hasRgb);
    await _prefsBox.put('motherboard', specs.motherboard);
    await _prefsBox.put('chassis_type', specs.chassisType);
    await _prefsBox.put('electricity_rate', state.electricityRate);
    await _prefsBox.put('currency_symbol', state.currencySymbol);
    await _prefsBox.put('daily_hours', state.dailyHours);
  }
}
