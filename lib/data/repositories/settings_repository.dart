import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';
import '../../core/constants/app_constants.dart';

class SettingsRepository {
  Box<AppSettings> get _box =>
      Hive.box<AppSettings>(AppConstants.hiveBoxSettings);

  AppSettings getSettings() {
    if (_box.isEmpty) {
      final defaults = AppSettings();
      _box.put('settings', defaults);
      return defaults;
    }
    return _box.get('settings') ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put('settings', settings);
  }

  Future<void> updateGoal(int ml) async {
    final s = getSettings();
    s.dailyGoalMl = ml;
    await _box.put('settings', s);
  }

  Future<void> updateCupSize(int ml) async {
    final s = getSettings();
    s.defaultCupSizeMl = ml;
    await _box.put('settings', s);
  }

  Future<void> setPremium(bool value) async {
    final s = getSettings();
    s.isPremium = value;
    await _box.put('settings', s);
  }
}
