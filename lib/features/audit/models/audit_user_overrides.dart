import 'package:equatable/equatable.dart';

class AuditUserOverrides extends Equatable {
  const AuditUserOverrides({
    this.cpuWattsOverride,
    this.gpuWattsOverride,
    this.motherboardWattsOverride,
    this.rgbWattsOverride,
    this.fanWattsEachOverride,
  });

  factory AuditUserOverrides.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const AuditUserOverrides();
    }

    return AuditUserOverrides(
      cpuWattsOverride: _toDouble(map['cpu_watts_override']),
      gpuWattsOverride: _toDouble(map['gpu_watts_override']),
      motherboardWattsOverride: _toDouble(map['motherboard_watts_override']),
      rgbWattsOverride: _toDouble(map['rgb_watts_override']),
      fanWattsEachOverride: _toDouble(map['fan_watts_each_override']),
    );
  }

  final double? cpuWattsOverride;
  final double? gpuWattsOverride;
  final double? motherboardWattsOverride;
  final double? rgbWattsOverride;
  final double? fanWattsEachOverride;

  bool get hasOverrides =>
      cpuWattsOverride != null ||
      gpuWattsOverride != null ||
      motherboardWattsOverride != null ||
      rgbWattsOverride != null ||
      fanWattsEachOverride != null;

  Map<String, dynamic> toMap() {
    return {
      'cpu_watts_override': cpuWattsOverride,
      'gpu_watts_override': gpuWattsOverride,
      'motherboard_watts_override': motherboardWattsOverride,
      'rgb_watts_override': rgbWattsOverride,
      'fan_watts_each_override': fanWattsEachOverride,
    };
  }

  static double? _toDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    return null;
  }

  @override
  List<Object?> get props => [
    cpuWattsOverride,
    gpuWattsOverride,
    motherboardWattsOverride,
    rgbWattsOverride,
    fanWattsEachOverride,
  ];
}
