import 'package:flutter_test/flutter_test.dart';
import 'package:watt_tracker/data/models/system_spec_model.dart';
import 'package:watt_tracker/data/services/energy_audit_service.dart';
import 'package:watt_tracker/features/audit/models/audit_activity_sample.dart';
import 'package:watt_tracker/features/audit/models/audit_user_overrides.dart';
import 'package:watt_tracker/features/audit/models/peripheral_profile.dart';

void main() {
  group('EnergyAuditService', () {
    test('builds deterministic breakdowns and tips from saved profile', () {
      final service = EnergyAuditService();

      final result = service.runAudit(
        spec: const SystemSpecModel(
          cpuName: 'Intel i5-12400',
          cpuTdpWatts: 65,
          gpuType: 'dedicated',
          gpuName: 'RTX 3060',
          gpuWatts: 170,
          ramGb: 16,
          ramSticks: 2,
          storageCount: 2,
          storageType: 'SSD',
          storageWattsEach: 3,
          fanCount: 5,
          hasRgb: true,
          rgbWatts: 10,
          motherboard: 'B660M',
          chassisType: 'desktop',
        ),
        ratePerKwh: 12,
        currencySymbol: 'PHP ',
        dailyHours: 8,
        overrides: const AuditUserOverrides(),
        peripherals: const <PeripheralProfile>[
          PeripheralProfile(
            id: 'monitor_1',
            label: 'Monitor',
            category: 'display',
            watts: 20,
            isEssential: false,
            source: 'user',
          ),
        ],
      );

      expect(result.breakdowns, isNotEmpty);
      expect(result.totalWatts, greaterThan(0));
      expect(result.findings.any((f) => f.type == 'idle_waste'), isTrue);
      expect(result.tips.length, lessThanOrEqualTo(3));
    });

    test('uses telemetry sample to increase idle confidence', () {
      final service = EnergyAuditService();

      final result = service.runAudit(
        spec: const SystemSpecModel(
          cpuName: 'Intel i7-12700K',
          cpuTdpWatts: 125,
          gpuType: 'dedicated',
          gpuName: 'RTX 4070',
          gpuWatts: 200,
          ramGb: 32,
          ramSticks: 2,
          storageCount: 2,
          storageType: 'SSD',
          storageWattsEach: 3,
          fanCount: 4,
          hasRgb: true,
          rgbWatts: 8,
          motherboard: 'Z690',
          chassisType: 'desktop',
        ),
        ratePerKwh: 13,
        currencySymbol: 'PHP ',
        dailyHours: 10,
        overrides: const AuditUserOverrides(),
        peripherals: const <PeripheralProfile>[],
        activitySample: const AuditActivitySample(
          cpuUsageAvg: 3,
          gpuUsageAvg: 2,
          wasSystemLocked: false,
          durationSeconds: 5,
        ),
      );

      final highConfidenceIdle = result.findings.where(
        (finding) =>
            finding.type == 'idle_waste' && finding.confidence == 'high',
      );

      expect(result.confidence, 'high');
      expect(highConfidenceIdle.isNotEmpty, isTrue);
      expect(result.dataCompleteness, greaterThan(0.8));
    });
  });
}
