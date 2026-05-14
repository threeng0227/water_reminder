import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  int dailyGoalMl;

  @HiveField(1)
  int defaultCupSizeMl;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  bool smartReminders;

  @HiveField(4)
  int reminderIntervalMinutes;

  @HiveField(5)
  int wakeHour;

  @HiveField(6)
  int sleepHour;

  @HiveField(7)
  bool isPremium;

  @HiveField(8)
  String selectedTheme;

  @HiveField(9)
  List<int> customCupSizes;

  @HiveField(10)
  bool motivationalNotifications;

  AppSettings({
    this.dailyGoalMl = 2000,
    this.defaultCupSizeMl = 250,
    this.notificationsEnabled = true,
    this.smartReminders = true,
    this.reminderIntervalMinutes = 60,
    this.wakeHour = 7,
    this.sleepHour = 22,
    this.isPremium = false,
    this.selectedTheme = 'default',
    List<int>? customCupSizes,
    this.motivationalNotifications = true,
  }) : customCupSizes = customCupSizes ?? [150, 200, 250, 300, 400, 500];
}
