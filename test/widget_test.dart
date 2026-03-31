// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:watt_tracker/data/local/hive_adapters.dart';
import 'package:watt_tracker/data/local/hive_boxes.dart';
import 'package:watt_tracker/data/models/component_model.dart';
import 'package:watt_tracker/data/models/device_model.dart';
import 'package:watt_tracker/data/models/session_model.dart';
import 'package:watt_tracker/data/repositories/wattwise_prefs_repository.dart';
import 'package:watt_tracker/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('watt_tracker_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DeviceTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DeviceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ComponentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ComponentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SessionModelAdapter());
    }

    await Future.wait([
      Hive.openBox<DeviceModel>(HiveBoxes.devices),
      Hive.openBox<ComponentModel>(HiveBoxes.components),
      Hive.openBox<SessionModel>(HiveBoxes.sessions),
      Hive.openBox<dynamic>(HiveBoxes.appPreferences),
      Hive.openBox<dynamic>(HiveBoxes.wattwisePrefs),
    ]);

    final prefs = Hive.box<dynamic>(HiveBoxes.wattwisePrefs);
    await prefs.put(WattwisePrefsRepository.onboardingCompleteKey, true);
    await prefs.put(WattwisePrefsRepository.cpuNameKey, 'Test CPU');
    await prefs.put(WattwisePrefsRepository.gpuTypeKey, 'integrated');
    await prefs.put(
      WattwisePrefsRepository.gpuNameKey,
      'Integrated Graphics',
    );
    await prefs.put(WattwisePrefsRepository.ramGbKey, 8);
    await prefs.put(WattwisePrefsRepository.ramSticksKey, 1);
    await prefs.put(WattwisePrefsRepository.storageCountKey, 1);
    await prefs.put(WattwisePrefsRepository.storageTypeKey, 'SSD');
    await prefs.put(WattwisePrefsRepository.fanCountKey, 1);
    await prefs.put(WattwisePrefsRepository.hasRgbKey, false);
    await prefs.put(WattwisePrefsRepository.motherboardKey, 'Test Board');
    await prefs.put(WattwisePrefsRepository.chassisTypeKey, 'desktop');
    await prefs.put(WattwisePrefsRepository.electricityRateKey, 12.0);
    await prefs.put(WattwisePrefsRepository.currencySymbolKey, '\u20B1');
    await prefs.put(WattwisePrefsRepository.dailyHoursKey, 8.0);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App boots on dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const WattWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('Test CPU'), findsOneWidget);
  });
}



