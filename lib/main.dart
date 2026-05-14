import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';
import 'core/theme/app_theme.dart';
import 'data/models/achievement.dart';
import 'data/models/app_settings.dart';
import 'data/models/reminder.dart';
import 'data/models/water_intake.dart';
import 'core/constants/app_constants.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(WaterIntakeAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(AchievementAdapter());

  await Future.wait([
    Hive.openBox<WaterIntake>(AppConstants.hiveBoxIntake),
    Hive.openBox<Reminder>(AppConstants.hiveBoxReminders),
    Hive.openBox<AppSettings>(AppConstants.hiveBoxSettings),
    Hive.openBox<Achievement>(AppConstants.hiveBoxStreaks),
  ]);

  await NotificationService().init();
  await AdService().init();

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(
    ProviderScope(
      child: WaterReminderApp(showOnboarding: !onboardingDone),
    ),
  );
}

class WaterReminderApp extends StatefulWidget {
  final bool showOnboarding;
  const WaterReminderApp({super.key, required this.showOnboarding});

  @override
  State<WaterReminderApp> createState() => _WaterReminderAppState();
}

class _WaterReminderAppState extends State<WaterReminderApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SplashScreen(
        nextScreen: _showOnboarding
            ? OnboardingScreen(
                onComplete: () => setState(() => _showOnboarding = false),
              )
            : const AppShell(),
      ),
    );
  }
}
