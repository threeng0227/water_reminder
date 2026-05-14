import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String formatTime(DateTime time) =>
      DateFormat('h:mm a').format(time);

  static String formatDayShort(DateTime date) =>
      DateFormat('EEE').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static List<DateTime> lastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) => startOfDay(now.subtract(Duration(days: n - 1 - i))));
  }

  /// All days of the current calendar week (Mon–Sun).
  static List<DateTime> currentWeekDays() {
    final now = startOfDay(DateTime.now());
    // weekday: 1=Mon … 7=Sun
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// All days of the current calendar month (1st … last day).
  static List<DateTime> currentMonthDays() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0); // day 0 of next month
    return List.generate(
      lastDay.day,
      (i) => firstDay.add(Duration(days: i)),
    );
  }

  static String relativeDay(DateTime date,
      {String todayLabel = 'Today', String yesterdayLabel = 'Yesterday'}) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return todayLabel;
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) return yesterdayLabel;
    return formatDate(date);
  }

  static int currentStreakFrom(List<DateTime> activeDays) {
    if (activeDays.isEmpty) return 0;
    final sorted = activeDays.map(startOfDay).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime expected = startOfDay(DateTime.now());
    for (final day in sorted) {
      if (isSameDay(day, expected)) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
