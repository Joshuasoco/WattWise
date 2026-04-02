import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watt_tracker/data/local/hive_boxes.dart';
import 'package:watt_tracker/data/repositories/energy_audit_repository.dart';
import 'package:watt_tracker/data/repositories/wattwise_prefs_repository.dart';
import 'package:watt_tracker/data/services/windows_activity_sampler.dart';
import 'package:watt_tracker/features/audit/cubit/energy_audit_cubit.dart';
import 'package:watt_tracker/features/audit/cubit/energy_audit_state.dart';
import 'package:watt_tracker/features/audit/models/audit_activity_sample.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> prefsBox;
  late Box<dynamic> auditBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('watt_tracker_audit_test_');
    Hive.init(tempDir.path);
    prefsBox = await Hive.openBox<dynamic>(HiveBoxes.wattwisePrefs);
    auditBox = await Hive.openBox<dynamic>(HiveBoxes.energyAudit);
  });

  tearDown(() async {
    await prefsBox.clear();
    await auditBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> seedPrefs() async {
    await prefsBox.putAll({
      WattwisePrefsRepository.cpuNameKey: 'Intel i5-12400',
      WattwisePrefsRepository.gpuTypeKey: 'dedicated',
      WattwisePrefsRepository.gpuNameKey: 'RTX 3060',
      WattwisePrefsRepository.ramGbKey: 16,
      WattwisePrefsRepository.ramSticksKey: 2,
      WattwisePrefsRepository.storageCountKey: 2,
      WattwisePrefsRepository.storageTypeKey: 'SSD',
      WattwisePrefsRepository.fanCountKey: 5,
      WattwisePrefsRepository.hasRgbKey: true,
      WattwisePrefsRepository.motherboardKey: 'B660M',
      WattwisePrefsRepository.chassisTypeKey: 'desktop',
      WattwisePrefsRepository.electricityRateKey: 12.0,
      WattwisePrefsRepository.currencySymbolKey: 'PHP ',
      WattwisePrefsRepository.dailyHoursKey: 8.0,
    });
  }

  test('runAudit emits loading then success with latest result', () async {
    await seedPrefs();

    final cubit = EnergyAuditCubit(
      auditRepository: EnergyAuditRepository(auditBox: auditBox),
      prefsRepository: WattwisePrefsRepository(prefsBox: prefsBox),
      activitySampler: const _FakeSampler(
        AuditActivitySample(
          cpuUsageAvg: 4,
          gpuUsageAvg: 3,
          wasSystemLocked: false,
          durationSeconds: 5,
        ),
      ),
    );

    final statuses = <EnergyAuditStatus>[];
    final sub = cubit.stream.listen((state) => statuses.add(state.status));

    await cubit.runAudit();

    await Future<void>.delayed(Duration.zero);

    expect(statuses, contains(EnergyAuditStatus.loading));
    expect(cubit.state.status, EnergyAuditStatus.success);
    expect(cubit.state.latestResult, isNotNull);

    await sub.cancel();
    await cubit.close();
  });

  test('dismissTip updates latest result tip state', () async {
    await seedPrefs();

    final cubit = EnergyAuditCubit(
      auditRepository: EnergyAuditRepository(auditBox: auditBox),
      prefsRepository: WattwisePrefsRepository(prefsBox: prefsBox),
      activitySampler: const _FakeSampler(
        AuditActivitySample(
          cpuUsageAvg: 6,
          gpuUsageAvg: 2,
          wasSystemLocked: false,
          durationSeconds: 5,
        ),
      ),
    );

    await cubit.runAudit();
    final firstTip = cubit.state.latestResult?.tips.first;
    expect(firstTip, isNotNull);

    await cubit.dismissTip(firstTip!.id);
    final updatedTip = cubit.state.latestResult!.tips.firstWhere(
      (t) => t.id == firstTip.id,
    );
    expect(updatedTip.isDismissed, isTrue);

    await cubit.close();
  });
}

class _FakeSampler extends WindowsActivitySampler {
  const _FakeSampler(this.sampleValue);

  final AuditActivitySample? sampleValue;

  @override
  Future<AuditActivitySample?> sample({
    Duration duration = const Duration(seconds: 5),
  }) async {
    return sampleValue;
  }
}
