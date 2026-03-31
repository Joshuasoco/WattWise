import 'package:flutter/material.dart';

import 'data/local/hive_boxes.dart';
import 'data/repositories/wattage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.initialize();

  final repository = WattageRepository();
  await repository.seedPresetsIfEmpty();

  runApp(const WattTrackerApp());
}

class WattTrackerApp extends StatelessWidget {
  const WattTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watt Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7E8C)),
      ),
      home: const Scaffold(
        body: Center(child: Text('Watt Tracker data layer ready')),
      ),
    );
  }
}
