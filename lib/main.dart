import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/local/hive_boxes.dart';
import 'data/repositories/app_preferences_repository.dart';
import 'data/repositories/wattage_repository.dart';
import 'features/calculator/cubit/cost_calculator_cubit.dart';
import 'features/history/cubit/history_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(960, 640),
      center: true,
      title: 'Watt Tracker',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await HiveBootstrap.initialize();

  final wattageRepository = WattageRepository();
  await wattageRepository.seedPresetsIfEmpty();
  final preferencesRepository = AppPreferencesRepository();

  runApp(
    WattTrackerApp(
      wattageRepository: wattageRepository,
      preferencesRepository: preferencesRepository,
    ),
  );
}

class WattTrackerApp extends StatelessWidget {
  const WattTrackerApp({
    super.key,
    required this.wattageRepository,
    required this.preferencesRepository,
  });

  final WattageRepository wattageRepository;
  final AppPreferencesRepository preferencesRepository;

  @override
  Widget build(BuildContext context) {
    final showOnboarding = !preferencesRepository.onboardingCompleted;
    final router = AppRouter.createRouter(showOnboarding: showOnboarding);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WattageRepository>(create: (_) => wattageRepository),
        RepositoryProvider<AppPreferencesRepository>(
          create: (_) => preferencesRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(preferencesRepository)),
          BlocProvider(
            create: (context) {
              final defaultRate = context
                  .read<SettingsCubit>()
                  .state
                  .defaultRatePerKwh;
              return CostCalculatorCubit()
                ..setDevice(WattageRepository.devicePresets.first)
                ..configureComponentWattage(WattageRepository.componentPresets)
                ..setRatePerKwh(defaultRate)
                ..setHours(4);
            },
          ),
          BlocProvider(
            create: (_) {
              final cubit = HistoryCubit(wattageRepository);
              cubit.loadSessions();
              return cubit;
            },
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp.router(
              title: 'Watt Tracker',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settingsState.themeMode,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
