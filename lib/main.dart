import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/local/hive_boxes.dart';
import 'data/repositories/wattwise_prefs_repository.dart';
import 'features/dashboard/cubit/live_timer_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveBootstrap.initialize();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await localNotifier.setup(
      appName: 'WattWise',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );

    const options = WindowOptions(
      size: Size(1024, 700),
      minimumSize: Size(800, 600),
      center: true,
      title: 'WattWise',
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const WattWiseApp());
}

class WattWiseApp extends StatefulWidget {
  const WattWiseApp({super.key});

  @override
  State<WattWiseApp> createState() => _WattWiseAppState();
}

class _WattWiseAppState extends State<WattWiseApp> {
  late final LiveTimerCubit _liveTimerCubit;

  @override
  void initState() {
    super.initState();
    _liveTimerCubit = LiveTimerCubit(
      prefsRepository: WattwisePrefsRepository(),
    );
  }

  @override
  void dispose() {
    unawaited(_liveTimerCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _liveTimerCubit,
      child: MaterialApp.router(
        title: 'WattWise',
        theme: AppTheme.light,
        routerConfig: AppRouter.createRouter(),
      ),
    );
  }
}
