import 'dart:io';

import '../../features/audit/models/audit_activity_sample.dart';

class WindowsActivitySampler {
  const WindowsActivitySampler();

  Future<AuditActivitySample?> sample({
    Duration duration = const Duration(seconds: 5),
  }) async {
    if (!Platform.isWindows) {
      return null;
    }

    final sampleSeconds = duration.inSeconds <= 0 ? 5 : duration.inSeconds;
    try {
      final cpu = await _sampleAverage(
        r'\Processor(_Total)\% Processor Time',
        sampleSeconds,
      );
      final gpu = await _sampleAverage(
        r'\GPU Engine(*)\Utilization Percentage',
        sampleSeconds,
      );
      final locked = await _isSystemLocked();

      return AuditActivitySample(
        cpuUsageAvg: cpu,
        gpuUsageAvg: gpu,
        wasSystemLocked: locked,
        durationSeconds: sampleSeconds,
      );
    } catch (_) {
      return null;
    }
  }

  Future<double> _sampleAverage(String counterPath, int seconds) async {
    final script =
      '\$counter = "$counterPath"; '
      '\$samples = Get-Counter -Counter \$counter -SampleInterval 1 -MaxSamples $seconds | Select-Object -ExpandProperty CounterSamples; '
      'if (\$samples) { (\$samples | Measure-Object -Property CookedValue -Average).Average } else { 0 }';

    final result = await Process.run('powershell', ['-Command', script]);
    if (result.exitCode != 0) {
      return 0;
    }

    final stdout = result.stdout.toString().trim();
    final parsed = double.tryParse(stdout);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return 0;
    }

    return parsed < 0 ? 0 : parsed;
  }

  Future<bool> _isSystemLocked() async {
    const script =
        r'if (Get-Process -Name LogonUI -ErrorAction SilentlyContinue) { "true" } else { "false" }';
    final result = await Process.run('powershell', ['-Command', script]);
    if (result.exitCode != 0) {
      return false;
    }

    return result.stdout.toString().trim().toLowerCase() == 'true';
  }
}
