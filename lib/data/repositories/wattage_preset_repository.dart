class WattagePresetRepository {
  static const Map<String, int> cpuTdpPresets = {
    'ryzen 5 5600g': 65,
    'ryzen 5 5600x': 65,
    'ryzen 5 7600': 65,
    'ryzen 7 5700x': 65,
    'ryzen 7 5800x': 105,
    'ryzen 7 7700x': 105,
    'ryzen 9 5900x': 105,
    'ryzen 9 7950x': 170,
    'i3-10100': 65,
    'i3-12100': 60,
    'i5-10400': 65,
    'i5-11400': 65,
    'i5-12400': 65,
    'i5-13400': 65,
    'i5-13600k': 125,
    'i7-10700': 65,
    'i7-11700': 65,
    'i7-12700k': 125,
    'i7-13700k': 125,
    'i9-10900k': 125,
    'i9-12900k': 125,
    'i9-13900k': 125,
    'i9-14900k': 125,
    'm1': 30,
    'm2': 35,
  };

  static const Map<String, int> gpuWattPresets = {
    'intel': 15,
    'vega': 35,
    'radeon rx 6600': 132,
    'radeon rx 6700 xt': 230,
    'radeon rx 6800': 250,
    'radeon rx 7600': 165,
    'rtx 2060': 160,
    'rtx 3060': 170,
    'rtx 3060 ti': 200,
    'rtx 3070': 220,
    'rtx 3080': 320,
    'rtx 3090': 350,
    'rtx 4060': 115,
    'rtx 4060 ti': 160,
    'rtx 4070': 200,
    'rtx 4070 ti': 285,
    'rtx 4080': 320,
    'rtx 4090': 450,
    'gtx 1050 ti': 75,
    'gtx 1060': 120,
    'gtx 1660': 120,
  };

  int resolveCpuTdp(String cpuName) {
    final normalized = cpuName.toLowerCase();
    for (final entry in cpuTdpPresets.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return 65;
  }

  int resolveGpuWatts(String gpuName, String gpuType) {
    if (gpuType == 'integrated') {
      return 15;
    }
    final normalized = gpuName.toLowerCase();
    for (final entry in gpuWattPresets.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return 150;
  }
}
