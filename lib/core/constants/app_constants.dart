class AppConstants {
  static const String appName = 'Water Reminder';
  static const String hiveBoxIntake = 'water_intake';
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxStreaks = 'streaks';
  static const String hiveBoxReminders = 'reminders';

  static const int defaultDailyGoalMl = 2000;
  static const int defaultCupSizeMl = 250;

  static const List<int> presetCupSizes = [150, 200, 250, 300, 350, 400, 500];

  static const String notificationChannelId = 'water_reminder_channel';
  static const String notificationChannelName = 'Water Reminders';
  static const String notificationChannelDesc = 'Reminders to drink water';

  static const String adBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String adRewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String adInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static const String widgetName = 'WaterReminderWidget';
  static const String widgetAuthor = 'com.unitysport.water_reminder';

  static const List<String> motivationalMessages = [
    "Take a sip — your body will thank you 💙",
    "Small sip, big energy. You've got this.",
    "Hydration check! Time for a quick drink.",
    "Your brain is 73% water. Keep it sharp.",
    "A little water goes a long way.",
    "Stay refreshed. Stay you.",
    "Your body called — it wants water.",
    "Sip by sip, you're doing great.",
    "Even champions pause to hydrate.",
    "Drink now, feel amazing later.",
    "Your skin is glowing — keep it up.",
    "One sip closer to your goal.",
  ];

  static const Map<String, int> achievementThresholds = {
    'first_sip': 1,
    'week_streak': 7,
    'month_streak': 30,
    'century': 100,
    'hydration_hero': 365,
  };
}
