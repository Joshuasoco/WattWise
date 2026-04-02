import 'package:equatable/equatable.dart';

class AuditActivitySample extends Equatable {
  const AuditActivitySample({
    required this.cpuUsageAvg,
    required this.gpuUsageAvg,
    required this.wasSystemLocked,
    required this.durationSeconds,
  });

  final double cpuUsageAvg;
  final double gpuUsageAvg;
  final bool wasSystemLocked;
  final int durationSeconds;

  bool get indicatesIdleWaste =>
      cpuUsageAvg < 8 && gpuUsageAvg < 5 && !wasSystemLocked;

  @override
  List<Object?> get props => [
    cpuUsageAvg,
    gpuUsageAvg,
    wasSystemLocked,
    durationSeconds,
  ];
}
