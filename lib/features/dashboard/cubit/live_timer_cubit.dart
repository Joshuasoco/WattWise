import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/system_spec_model.dart';
import '../../../data/repositories/wattage_preset_repository.dart';
import '../../../data/repositories/wattwise_prefs_repository.dart';
import 'live_timer_state.dart';

class LiveTimerCubit extends Cubit<LiveTimerState> {
  LiveTimerCubit({
    required WattwisePrefsRepository prefsRepository,
    WattagePresetRepository? presetRepository,
  }) : _prefsRepository = prefsRepository,
       _presetRepository = presetRepository ?? WattagePresetRepository(),
       super(LiveTimerState.initial()) {
    _initializeFromPrefs();
  }

  final WattwisePrefsRepository _prefsRepository;
  final WattagePresetRepository _presetRepository;
  StreamSubscription<int>? _tickerSub;

  void _initializeFromPrefs() {
    final savedSpec = _prefsRepository.systemSpec;
    final rate = _prefsRepository.electricityRate;
    final dailyHours = _prefsRepository.dailyHours;
    final currencySymbol = _prefsRepository.currencySymbol;

    final spec = savedSpec.copyWith(
      cpuTdpWatts: _presetRepository.resolveCpuTdp(savedSpec.cpuName),
      gpuWatts: _presetRepository.resolveGpuWatts(
        savedSpec.gpuName,
        savedSpec.gpuType,
      ),
      storageWattsEach: savedSpec.storageType == 'HDD' ? 7 : 3,
      rgbWatts: savedSpec.hasRgb ? 10 : 0,
    );

    emit(
      state.copyWith(
        spec: spec,
        currencySymbol: currencySymbol,
        ratePerKwh: rate,
        dailyHours: dailyHours,
        costPerSecond: spec.costPerSecond(rate),
      ),
    );

    startTimer();
  }

  void startTimer() {
    if (state.isRunning) return;
    emit(state.copyWith(isRunning: true));

    _tickerSub?.cancel();
    _tickerSub = Stream.periodic(const Duration(seconds: 1), (tick) => tick)
        .listen((_) {
          emit(
            state.copyWith(
              elapsedSeconds: state.elapsedSeconds + 1,
              totalCostAccumulated:
                  state.totalCostAccumulated + state.costPerSecond,
              isRunning: true,
            ),
          );
        });
  }

  void pauseTimer() {
    _tickerSub?.cancel();
    _tickerSub = null;
    emit(state.copyWith(isRunning: false));
  }

  void resetTimer() {
    _tickerSub?.cancel();
    _tickerSub = null;
    emit(
      state.copyWith(
        elapsedSeconds: 0,
        totalCostAccumulated: 0,
        isRunning: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _tickerSub?.cancel();
    return super.close();
  }
}
