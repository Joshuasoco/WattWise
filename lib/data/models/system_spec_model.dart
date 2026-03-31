class SystemSpecModel {
  const SystemSpecModel({
    required this.cpuName,
    required this.cpuTdpWatts,
    required this.gpuType,
    required this.gpuName,
    required this.gpuWatts,
    required this.ramGb,
    required this.ramSticks,
    this.ramWattsPerStick = 3,
    required this.storageCount,
    required this.storageType,
    required this.storageWattsEach,
    required this.fanCount,
    this.fansWattsEach = 2,
    required this.hasRgb,
    required this.rgbWatts,
    this.motherboardWatts = 50,
    required this.motherboard,
    required this.chassisType,
  });

  factory SystemSpecModel.defaults() {
    return const SystemSpecModel(
      cpuName: 'Unknown CPU',
      cpuTdpWatts: 65,
      gpuType: 'integrated',
      gpuName: 'Integrated Graphics',
      gpuWatts: 15,
      ramGb: 8,
      ramSticks: 1,
      storageCount: 1,
      storageType: 'SSD',
      storageWattsEach: 3,
      fanCount: 1,
      hasRgb: false,
      rgbWatts: 0,
      motherboard: 'Unknown Motherboard',
      chassisType: 'desktop',
    );
  }

  final String cpuName;
  final int cpuTdpWatts;
  final String gpuType;
  final String gpuName;
  final int gpuWatts;
  final int ramGb;
  final int ramSticks;
  final int ramWattsPerStick;
  final int storageCount;
  final String storageType;
  final int storageWattsEach;
  final int fanCount;
  final int fansWattsEach;
  final bool hasRgb;
  final int rgbWatts;
  final int motherboardWatts;
  final String motherboard;
  final String chassisType;

  int get totalWatts {
    final rgbLoad = hasRgb ? rgbWatts : 0;
    return cpuTdpWatts +
        gpuWatts +
        (ramSticks * ramWattsPerStick) +
        (storageCount * storageWattsEach) +
        (fanCount * fansWattsEach) +
        rgbLoad +
        motherboardWatts;
  }

  double costPerSecond(double rateKwh) {
    return (totalWatts / 1000) * rateKwh / 3600;
  }

  Map<String, dynamic> toPrefsMap() {
    return {
      'cpu_name': cpuName,
      'gpu_type': gpuType,
      'gpu_name': gpuName,
      'ram_gb': ramGb,
      'ram_sticks': ramSticks,
      'storage_count': storageCount,
      'storage_type': storageType,
      'fan_count': fanCount,
      'has_rgb': hasRgb,
      'motherboard': motherboard,
      'chassis_type': chassisType,
    };
  }

  SystemSpecModel copyWith({
    String? cpuName,
    int? cpuTdpWatts,
    String? gpuType,
    String? gpuName,
    int? gpuWatts,
    int? ramGb,
    int? ramSticks,
    int? ramWattsPerStick,
    int? storageCount,
    String? storageType,
    int? storageWattsEach,
    int? fanCount,
    int? fansWattsEach,
    bool? hasRgb,
    int? rgbWatts,
    int? motherboardWatts,
    String? motherboard,
    String? chassisType,
  }) {
    return SystemSpecModel(
      cpuName: cpuName ?? this.cpuName,
      cpuTdpWatts: cpuTdpWatts ?? this.cpuTdpWatts,
      gpuType: gpuType ?? this.gpuType,
      gpuName: gpuName ?? this.gpuName,
      gpuWatts: gpuWatts ?? this.gpuWatts,
      ramGb: ramGb ?? this.ramGb,
      ramSticks: ramSticks ?? this.ramSticks,
      ramWattsPerStick: ramWattsPerStick ?? this.ramWattsPerStick,
      storageCount: storageCount ?? this.storageCount,
      storageType: storageType ?? this.storageType,
      storageWattsEach: storageWattsEach ?? this.storageWattsEach,
      fanCount: fanCount ?? this.fanCount,
      fansWattsEach: fansWattsEach ?? this.fansWattsEach,
      hasRgb: hasRgb ?? this.hasRgb,
      rgbWatts: rgbWatts ?? this.rgbWatts,
      motherboardWatts: motherboardWatts ?? this.motherboardWatts,
      motherboard: motherboard ?? this.motherboard,
      chassisType: chassisType ?? this.chassisType,
    );
  }
}
