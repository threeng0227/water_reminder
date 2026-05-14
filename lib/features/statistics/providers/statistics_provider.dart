import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../settings/providers/settings_provider.dart';
import '../../home/providers/intake_provider.dart';

final statisticsProvider = Provider<StatisticsData>((ref) {
  ref.watch(todayIntakesProvider); // rebuild when today's intakes change
  final repo = ref.read(intakeRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final weeklyTotals = repo.getCurrentWeekTotals();
  final monthlyTotals = repo.getCurrentMonthTotals();

  // Only average days that have already passed (don't count future days as 0)
  final today = AppDateUtils.startOfDay(DateTime.now());
  final passedEntries = weeklyTotals.entries
      .where((e) => !e.key.isAfter(today))
      .toList();
  final weeklyAvg = passedEntries.isEmpty
      ? 0
      : passedEntries.fold(0, (sum, e) => sum + e.value) ~/
          passedEntries.length;

  int weeklyGoalDays = 0;
  for (final e in passedEntries) {
    if (e.value >= settings.dailyGoalMl) weeklyGoalDays++;
  }

  final activeDays = repo.getDaysWithAnyIntake();
  final streak = AppDateUtils.currentStreakFrom(activeDays);

  // Find best streak
  int bestStreak = 0;
  int current = 0;
  final sorted = activeDays.toSet().toList()..sort();
  for (int i = 0; i < sorted.length; i++) {
    if (i == 0) {
      current = 1;
    } else {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      current = diff == 1 ? current + 1 : 1;
    }
    if (current > bestStreak) bestStreak = current;
  }

  return StatisticsData(
    weeklyTotals: weeklyTotals,
    monthlyTotals: monthlyTotals,
    weeklyAvgMl: weeklyAvg,
    weeklyGoalDays: weeklyGoalDays,
    weekDaysPassed: passedEntries.length,
    currentStreak: streak,
    bestStreak: bestStreak,
    totalAllTime: repo.getTotalAllTime(),
    goalMl: settings.dailyGoalMl,
  );
});

class StatisticsData {
  final Map<DateTime, int> weeklyTotals;
  final Map<DateTime, int> monthlyTotals;
  final int weeklyAvgMl;
  final int weeklyGoalDays;
  final int weekDaysPassed;
  final int currentStreak;
  final int bestStreak;
  final int totalAllTime;
  final int goalMl;

  const StatisticsData({
    required this.weeklyTotals,
    required this.monthlyTotals,
    required this.weeklyAvgMl,
    required this.weeklyGoalDays,
    required this.weekDaysPassed,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalAllTime,
    required this.goalMl,
  });
}
