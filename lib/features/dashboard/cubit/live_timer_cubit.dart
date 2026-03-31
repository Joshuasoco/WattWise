import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models/system_spec_model.dart';
import '../../../data/repositories/wattage_preset_repository.dart';
import 'live_timer_state.dart';

class LiveTimerCubit extends Cubit<LiveTimerState> {
  LiveTimerCubit({
    required Box<dynamic> prefsBox,
    WattagePresetRepository? presetRepository,
  }) : _prefsBox = prefsBox,
       _presetRepository = presetRepository ?? WattagePresetRepository(),
       super(LiveTimerState.initial()) {
    _initializeFromPrefs();
  }

  final Box<dynamic> _prefsBox;
  final WattagePresetRepository _presetRepository;
  StreamSubscription<int>? _tickerSub;

  void _initializeFromPrefs() {
    final cpuName = (_prefsBox.get('cpu_name') as String?) ?? 'Unknown CPU';
    final gpuType = (_prefsBox.get('gpu_type') as String?) ?? 'integrated';
    final gpuName =
        (_prefsBox.get('gpu_name') as String?) ?? 'Integrated Graphics';
    final ramGb = (_prefsBox.get('ram_gb') as int?) ?? 8;
    final ramSticks = (_prefsBox.get('ram_sticks') as int?) ?? 1;
    final storageCount = (_prefsBox.get('storage_count') as int?) ?? 1;
    final storageType = (_prefsBox.get('storage_type') as String?) ?? 'SSD';
    final fanCount = (_prefsBox.get('fan_count') as int?) ?? 1;
    final hasRgb = (_prefsBox.get('has_rgb') as bool?) ?? false;
    final motherboard =
        (_prefsBox.get('motherboard') as String?) ?? 'Unknown Motherboard';
    final chassisType = (_prefsBox.get('chassis_type') as String?) ?? 'desktop';

    final currencySymbol = (_prefsBox.get('currency_symbol') as String?) ?? '₱';
    final rate = ((_prefsBox.get('electricity_rate') as num?) ?? 12).toDouble();
    final dailyHours = ((_prefsBox.get('daily_hours') as num?) ?? 8).toDouble();

    final cpuTdp = _presetRepository.resolveCpuTdp(cpuName);
    final gpuWatts = _presetRepository.resolveGpuWatts(gpuName, gpuType);
    final storageWattsEach = storageType == 'HDD' ? 7 : 3;

    final spec = SystemSpecModel(
      cpuName: cpuName,
      cpuTdpWatts: cpuTdp,
      gpuType: gpuType,
      gpuName: gpuName,
      gpuWatts: gpuWatts,
      ramGb: ramGb,
      ramSticks: ramSticks,
      storageCount: storageCount,
      storageType: storageType,
      storageWattsEach: storageWattsEach,
      fanCount: fanCount,
      hasRgb: hasRgb,
      rgbWatts: hasRgb ? 10 : 0,
      motherboard: motherboard,
      chassisType: chassisType,
    );

    final cps = spec.costPerSecond(rate);

    emit(
      state.copyWith(
        spec: spec,
        currencySymbol: currencySymbol,
        ratePerKwh: rate,
        dailyHours: dailyHours,
        costPerSecond: cps,
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
