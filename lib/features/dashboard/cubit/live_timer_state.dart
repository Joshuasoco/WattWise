import 'package:equatable/equatable.dart';

import '../../../data/models/system_spec_model.dart';

class LiveTimerState extends Equatable {
  const LiveTimerState({
    required this.spec,
    this.currencySymbol = '₱',
    this.ratePerKwh = 12,
    this.dailyHours = 8,
    this.elapsedSeconds = 0,
    this.totalCostAccumulated = 0,
    this.costPerSecond = 0,
    this.isRunning = false,
  });

  factory LiveTimerState.initial() {
    return LiveTimerState(spec: SystemSpecModel.defaults());
  }

  final SystemSpecModel spec;
  final String currencySymbol;
  final double ratePerKwh;
  final double dailyHours;
  final int elapsedSeconds;
  final double totalCostAccumulated;
  final double costPerSecond;
  final bool isRunning;

  double get perHour => costPerSecond * 3600;
  double get perDay => perHour * dailyHours;
  double get perMonth => perDay * 30;

  LiveTimerState copyWith({
    SystemSpecModel? spec,
    String? currencySymbol,
    double? ratePerKwh,
    double? dailyHours,
    int? elapsedSeconds,
    double? totalCostAccumulated,
    double? costPerSecond,
    bool? isRunning,
  }) {
    return LiveTimerState(
      spec: spec ?? this.spec,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      ratePerKwh: ratePerKwh ?? this.ratePerKwh,
      dailyHours: dailyHours ?? this.dailyHours,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalCostAccumulated: totalCostAccumulated ?? this.totalCostAccumulated,
      costPerSecond: costPerSecond ?? this.costPerSecond,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object?> get props => [
    spec,
    currencySymbol,
    ratePerKwh,
    dailyHours,
    elapsedSeconds,
    totalCostAccumulated,
    costPerSecond,
    isRunning,
  ];
}
