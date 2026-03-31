import 'dart:io';

import '../models/system_spec_model.dart';
import '../repositories/wattage_preset_repository.dart';

class SystemScanService {
  SystemScanService({WattagePresetRepository? presetRepository})
    : _presetRepository = presetRepository ?? WattagePresetRepository();

  final WattagePresetRepository _presetRepository;

  Future<SystemSpecModel> scanSystem({
    void Function(SystemScanProgress progress)? onProgress,
  }) async {
    final defaults = SystemSpecModel.defaults();

    String cpuName = defaults.cpuName;
    int cpuTdp = defaults.cpuTdpWatts;
    String gpuName = defaults.gpuName;
    String gpuType = defaults.gpuType;
    int gpuWatts = defaults.gpuWatts;
    int ramGb = defaults.ramGb;
    int ramSticks = defaults.ramSticks;
    int storageCount = defaults.storageCount;
    String storageType = defaults.storageType;
    int fanCount = defaults.fanCount;
    bool hasRgb = defaults.hasRgb;
    String motherboard = defaults.motherboard;
    String chassisType = defaults.chassisType;
    var cpuScanned = false;
    var gpuScanned = false;
    var ramScanned = false;
    var storageScanned = false;
    var motherboardScanned = false;

    void emitProgress() {
      onProgress?.call(
        SystemScanProgress(
          specs: _buildSpec(
            cpuName: cpuName,
            cpuTdp: cpuTdp,
            gpuName: gpuName,
            gpuType: gpuType,
            gpuWatts: gpuWatts,
            ramGb: ramGb,
            ramSticks: ramSticks,
            storageCount: storageCount,
            storageType: storageType,
            fanCount: fanCount,
            hasRgb: hasRgb,
            motherboard: motherboard,
            chassisType: chassisType,
          ),
          cpuScanned: cpuScanned,
          gpuScanned: gpuScanned,
          ramScanned: ramScanned,
          storageScanned: storageScanned,
          motherboardScanned: motherboardScanned,
        ),
      );
    }

    try {
      cpuName = await _scanCpuName();
      cpuTdp = _presetRepository.resolveCpuTdp(cpuName);
    } catch (_) {}
    cpuScanned = true;
    emitProgress();

    try {
      final gpuInfo = await _scanGpuInfo();
      gpuName = gpuInfo.name;
      gpuType = gpuInfo.type;
      gpuWatts = _presetRepository.resolveGpuWatts(gpuName, gpuType);
    } catch (_) {}
    gpuScanned = true;
    emitProgress();

    try {
      final ramInfo = await _scanRamInfo();
      ramGb = ramInfo.totalGb;
      ramSticks = ramInfo.stickCount;
    } catch (_) {}
    ramScanned = true;
    emitProgress();

    try {
      final storageInfo = await _scanStorageInfo();
      storageCount = storageInfo.count;
      storageType = storageInfo.type;
    } catch (_) {}
    storageScanned = true;
    emitProgress();

    try {
      motherboard = await _scanMotherboard();
    } catch (_) {}
    motherboardScanned = true;
    emitProgress();

    if (cpuName.toLowerCase().contains('mobile') ||
        cpuName.toLowerCase().contains('u-') ||
        gpuType == 'integrated') {
      chassisType = 'laptop';
      fanCount = 1;
    } else {
      chassisType = 'desktop';
      fanCount = 3;
      hasRgb = true;
    }

    return _buildSpec(
      cpuName: cpuName,
      cpuTdp: cpuTdp,
      gpuName: gpuName,
      gpuType: gpuType,
      gpuWatts: gpuWatts,
      ramGb: ramGb,
      ramSticks: ramSticks,
      storageCount: storageCount,
      storageType: storageType,
      fanCount: fanCount,
      hasRgb: hasRgb,
      motherboard: motherboard,
      chassisType: chassisType,
    );
  }

  Future<String> _scanCpuName() async {
    try {
      const script =
          'Get-WmiObject Win32_Processor | Select-Object -ExpandProperty Name';
      final result = await _runPowerShell(script);
      final lines = _cleanLines(result.stdout.toString());
      if (lines.isNotEmpty) {
        return lines.first;
      }
    } catch (_) {}

    final registryValue = await _readRegistryValue(
      r'HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0',
      'ProcessorNameString',
    );
    return registryValue ?? 'Unknown CPU';
  }

  Future<_GpuInfo> _scanGpuInfo() async {
    const script =
        'Get-WmiObject Win32_VideoController | Select-Object Name, AdapterRAM';
    final result = await _runPowerShell(script);
    final lines = _cleanLines(result.stdout.toString());

    if (lines.isEmpty) {
      return const _GpuInfo(name: 'Integrated Graphics', type: 'integrated');
    }

    final dataRows = _extractTableDataRows(
      lines,
      excludedHeaders: const ['name', 'adapterram'],
    );

    if (dataRows.isEmpty) {
      return const _GpuInfo(name: 'Integrated Graphics', type: 'integrated');
    }

    final row = dataRows.first.replaceAll(RegExp(r'\s+'), ' ').trim();
    final parts = row.split(' ');
    final adapterRamRaw =
        int.tryParse(parts.isNotEmpty ? parts.last : '0') ?? 0;
    final name = row.replaceFirst(RegExp(r'\s+\d+$'), '').trim();
    final isIntegrated =
        adapterRamRaw < 2147483648 ||
        name.toLowerCase().contains('intel') ||
        name.toLowerCase().contains('vega');

    return _GpuInfo(
      name: name.isEmpty ? 'Integrated Graphics' : name,
      type: isIntegrated ? 'integrated' : 'dedicated',
    );
  }

  Future<_RamInfo> _scanRamInfo() async {
    try {
      const totalScript =
          'Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object -ExpandProperty Sum';
      const countScript =
          'Get-WmiObject Win32_PhysicalMemory | Measure-Object | Select-Object -ExpandProperty Count';

      final totalResult = await _runPowerShell(totalScript);
      final countResult = await _runPowerShell(countScript);

      final totalRaw = int.tryParse(
        _cleanLines(totalResult.stdout.toString()).join('').trim(),
      );
      final countRaw = int.tryParse(
        _cleanLines(countResult.stdout.toString()).join('').trim(),
      );

      if (totalRaw != null) {
        final totalGb = (totalRaw / 1024 / 1024 / 1024).ceil();
        return _RamInfo(totalGb: totalGb, stickCount: countRaw ?? 1);
      }
    } catch (_) {}

    try {
      const script =
          'Add-Type -AssemblyName Microsoft.VisualBasic; '
          '[Microsoft.VisualBasic.Devices.ComputerInfo]::new().TotalPhysicalMemory';
      final result = await _runPowerShell(script);
      final totalRaw = int.tryParse(
        _cleanLines(result.stdout.toString()).join('').trim(),
      );
      if (totalRaw != null) {
        return _RamInfo(
          totalGb: (totalRaw / 1024 / 1024 / 1024).ceil(),
          stickCount: 1,
        );
      }
    } catch (_) {}

    return const _RamInfo(totalGb: 8, stickCount: 1);
  }

  Future<_StorageInfo> _scanStorageInfo() async {
    try {
      const script =
          'Get-WmiObject Win32_DiskDrive | Select-Object Model, Size';
      final result = await _runPowerShell(script);
      final lines = _cleanLines(result.stdout.toString());

      final dataRows = _extractTableDataRows(
        lines,
        excludedHeaders: const ['model', 'size'],
      );

      if (dataRows.isNotEmpty) {
        return _StorageInfo(
          count: dataRows.length,
          type: _inferStorageType(dataRows.join(' ')),
        );
      }
    } catch (_) {}

    final registryDrives = await _scanStorageFromRegistry();
    if (registryDrives.isNotEmpty) {
      return _StorageInfo(
        count: registryDrives.length,
        type: _inferStorageType(registryDrives.join(' ')),
      );
    }

    return const _StorageInfo(count: 1, type: 'SSD');
  }

  Future<String> _scanMotherboard() async {
    try {
      const script =
          'Get-WmiObject Win32_BaseBoard | Select-Object -ExpandProperty Product';
      final result = await _runPowerShell(script);
      final lines = _cleanLines(result.stdout.toString());
      if (lines.isNotEmpty) {
        return lines.first;
      }
    } catch (_) {}

    final registryValue = await _readRegistryValue(
      r'HKLM\HARDWARE\DESCRIPTION\System\BIOS',
      'BaseBoardProduct',
    );
    return registryValue ?? 'Unknown Motherboard';
  }

  Future<List<String>> _scanStorageFromRegistry() async {
    final result = await Process.run('reg', [
      'query',
      r'HKLM\SYSTEM\CurrentControlSet\Services\disk\Enum',
    ]);
    if (result.exitCode != 0) {
      return const [];
    }

    final lines = _cleanLines(result.stdout.toString());
    final entries = <String>[];

    for (final line in lines) {
      final match = RegExp(r'^(\d+)\s+REG_SZ\s+(.+)$').firstMatch(line);
      if (match != null) {
        entries.add(match.group(2)!.trim());
      }
    }

    return entries;
  }

  Future<String?> _readRegistryValue(String path, String valueName) async {
    final result = await Process.run('reg', ['query', path, '/v', valueName]);
    if (result.exitCode != 0) {
      return null;
    }

    for (final line in _cleanLines(result.stdout.toString())) {
      if (!line.startsWith(valueName)) {
        continue;
      }

      final parts = line.split(RegExp(r'\s{2,}'));
      if (parts.length >= 3) {
        return parts.last.trim();
      }
    }

    return null;
  }

  String _inferStorageType(String combinedDetails) {
    final normalized = combinedDetails.toLowerCase();
    final hasHddKeyword =
        normalized.contains('hdd') ||
        normalized.contains('wdc') ||
        normalized.contains('st1000') ||
        normalized.contains('toshiba') ||
        normalized.contains('seagate');
    final hasSsdKeyword =
        normalized.contains('ssd') ||
        normalized.contains('nvme') ||
        normalized.contains('adata') ||
        normalized.contains('kingston') ||
        normalized.contains('samsung') ||
        normalized.contains('crucial') ||
        normalized.contains('p4-') ||
        normalized.contains('su');

    if (hasHddKeyword && !hasSsdKeyword) {
      return 'HDD';
    }
    return 'SSD';
  }

  Future<ProcessResult> _runPowerShell(String script) async {
    final result = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      script,
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        'powershell',
        ['-NoProfile', '-Command', script],
        result.stderr.toString(),
        result.exitCode,
      );
    }
    return result;
  }

  SystemSpecModel _buildSpec({
    required String cpuName,
    required int cpuTdp,
    required String gpuName,
    required String gpuType,
    required int gpuWatts,
    required int ramGb,
    required int ramSticks,
    required int storageCount,
    required String storageType,
    required int fanCount,
    required bool hasRgb,
    required String motherboard,
    required String chassisType,
  }) {
    final storageWattsEach = storageType == 'HDD' ? 7 : 3;
    final rgbWatts = hasRgb ? 10 : 0;

    return SystemSpecModel(
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
      rgbWatts: rgbWatts,
      motherboard: motherboard,
      chassisType: chassisType,
    );
  }

  List<String> _cleanLines(String output) {
    return output
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> _extractTableDataRows(
    List<String> lines, {
    required List<String> excludedHeaders,
  }) {
    return lines.where((line) {
      final normalized = line.toLowerCase();
      final isHeader = excludedHeaders.any(normalized.contains);
      final isDivider = line.replaceAll(RegExp(r'[-\s]'), '').isEmpty;
      return !isHeader && !isDivider;
    }).toList();
  }
}

class _GpuInfo {
  const _GpuInfo({required this.name, required this.type});

  final String name;
  final String type;
}

class _RamInfo {
  const _RamInfo({required this.totalGb, required this.stickCount});

  final int totalGb;
  final int stickCount;
}

class _StorageInfo {
  const _StorageInfo({required this.count, required this.type});

  final int count;
  final String type;
}

class SystemScanProgress {
  const SystemScanProgress({
    required this.specs,
    required this.cpuScanned,
    required this.gpuScanned,
    required this.ramScanned,
    required this.storageScanned,
    required this.motherboardScanned,
  });

  final SystemSpecModel specs;
  final bool cpuScanned;
  final bool gpuScanned;
  final bool ramScanned;
  final bool storageScanned;
  final bool motherboardScanned;
}
