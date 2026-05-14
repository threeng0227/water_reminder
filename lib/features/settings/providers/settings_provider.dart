import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../services/notification_service.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(_repo.getSettings());

  Future<void> updateGoal(int ml) async {
    state = state..dailyGoalMl = ml;
    await _repo.saveSettings(state);
    state = AppSettings()
      ..dailyGoalMl = ml
      ..defaultCupSizeMl = state.defaultCupSizeMl
      ..notificationsEnabled = state.notificationsEnabled
      ..smartReminders = state.smartReminders
      ..reminderIntervalMinutes = state.reminderIntervalMinutes
      ..wakeHour = state.wakeHour
      ..sleepHour = state.sleepHour
      ..isPremium = state.isPremium
      ..selectedTheme = state.selectedTheme
      ..customCupSizes = state.customCupSizes
      ..motivationalNotifications = state.motivationalNotifications;
  }

  Future<void> save(AppSettings updated) async {
    await _repo.saveSettings(updated);
    state = updated;
    if (updated.smartReminders && updated.notificationsEnabled) {
      await NotificationService().scheduleSmartReminders(
        intervalMinutes: updated.reminderIntervalMinutes,
        wakeHour: updated.wakeHour,
        sleepHour: updated.sleepHour,
      );
    } else {
      await NotificationService().cancelSmartReminders();
    }
  }

  Future<void> setPremium(bool value) async {
    final updated = _copyWith(isPremium: value);
    await _repo.saveSettings(updated);
    state = updated;
  }

  AppSettings _copyWith({
    int? dailyGoalMl,
    int? defaultCupSizeMl,
    bool? notificationsEnabled,
    bool? smartReminders,
    int? reminderIntervalMinutes,
    int? wakeHour,
    int? sleepHour,
    bool? isPremium,
    String? selectedTheme,
    List<int>? customCupSizes,
    bool? motivationalNotifications,
  }) {
    return AppSettings(
      dailyGoalMl: dailyGoalMl ?? state.dailyGoalMl,
      defaultCupSizeMl: defaultCupSizeMl ?? state.defaultCupSizeMl,
      notificationsEnabled: notificationsEnabled ?? state.notificationsEnabled,
      smartReminders: smartReminders ?? state.smartReminders,
      reminderIntervalMinutes: reminderIntervalMinutes ?? state.reminderIntervalMinutes,
      wakeHour: wakeHour ?? state.wakeHour,
      sleepHour: sleepHour ?? state.sleepHour,
      isPremium: isPremium ?? state.isPremium,
      selectedTheme: selectedTheme ?? state.selectedTheme,
      customCupSizes: customCupSizes ?? state.customCupSizes,
      motivationalNotifications: motivationalNotifications ?? state.motivationalNotifications,
    );
  }
}

final isDarkModeProvider = Provider<bool>((ref) => true);
