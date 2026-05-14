import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/water_intake.dart';
import '../../../data/repositories/intake_repository.dart';
import '../../../services/notification_service.dart';
import '../../../services/widget_service.dart';
import '../../settings/providers/settings_provider.dart';
import 'streak_provider.dart';

final intakeRepositoryProvider = Provider<IntakeRepository>((ref) {
  return IntakeRepository();
});

final todayIntakesProvider =
    StateNotifierProvider<TodayIntakesNotifier, List<WaterIntake>>((ref) {
  return TodayIntakesNotifier(ref);
});

class TodayIntakesNotifier extends StateNotifier<List<WaterIntake>> {
  final Ref _ref;
  Timer? _midnightTimer;

  TodayIntakesNotifier(this._ref)
      : super(_ref.read(intakeRepositoryProvider).getForDay(DateTime.now())) {
    _scheduleMidnightReset();
  }

  int get totalMl => state.fold(0, (sum, e) => sum + e.amountMl);

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final delay = midnight.difference(now);
    _midnightTimer = Timer(delay, () {
      reload();
      _ref.read(streakProvider.notifier).recalculate();
      _syncWidget();
      _scheduleMidnightReset();
    });
  }

  Future<void> addIntake(int amountMl, {String cupType = 'glass'}) async {
    final repo = _ref.read(intakeRepositoryProvider);
    await repo.addIntake(amountMl, cupType: cupType);
    state = repo.getForDay(DateTime.now());
    _ref.read(streakProvider.notifier).recalculate();
    _syncWidget();
    _rescheduleSmartReminders();
  }

  Future<void> removeIntake(String id) async {
    final repo = _ref.read(intakeRepositoryProvider);
    await repo.removeIntake(id);
    state = repo.getForDay(DateTime.now());
    _ref.read(streakProvider.notifier).recalculate();
    _syncWidget();
  }

  void reload() {
    state = _ref.read(intakeRepositoryProvider).getForDay(DateTime.now());
  }

  void _syncWidget() {
    final settings = _ref.read(settingsProvider);
    final streak = _ref.read(streakProvider);
    WidgetService.updateWidget(
      currentMl: totalMl,
      goalMl: settings.dailyGoalMl,
      streak: streak,
    );
  }

  void _rescheduleSmartReminders() {
    final settings = _ref.read(settingsProvider);
    if (!settings.smartReminders) return;
    NotificationService().scheduleSmartReminders(
      intervalMinutes: settings.reminderIntervalMinutes,
      wakeHour: settings.wakeHour,
      sleepHour: settings.sleepHour,
    );
  }
}

final todayTotalMlProvider = Provider<int>((ref) {
  final intakes = ref.watch(todayIntakesProvider);
  return intakes.fold(0, (sum, e) => sum + e.amountMl);
});

final dailyProgressProvider = Provider<double>((ref) {
  final total = ref.watch(todayTotalMlProvider);
  final settings = ref.watch(settingsProvider);
  return (total / settings.dailyGoalMl).clamp(0.0, 1.0);
});

final isGoalReachedProvider = Provider<bool>((ref) {
  return ref.watch(dailyProgressProvider) >= 1.0;
});
