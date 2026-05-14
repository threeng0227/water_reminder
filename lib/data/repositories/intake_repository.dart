import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/water_intake.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class IntakeRepository {
  Box<WaterIntake> get _box => Hive.box<WaterIntake>(AppConstants.hiveBoxIntake);

  List<WaterIntake> getAll() => _box.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<WaterIntake> getForDay(DateTime day) => _box.values
      .where((e) => AppDateUtils.isSameDay(e.timestamp, day))
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  int getTotalMlForDay(DateTime day) =>
      getForDay(day).fold(0, (sum, e) => sum + e.amountMl);

  Future<void> addIntake(int amountMl, {String cupType = 'glass'}) async {
    final intake = WaterIntake(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      amountMl: amountMl,
      cupType: cupType,
    );
    await _box.put(intake.id, intake);
  }

  Future<void> removeIntake(String id) async {
    await _box.delete(id);
  }

  Map<DateTime, int> getDailyTotals(int days) {
    final result = <DateTime, int>{};
    for (final day in AppDateUtils.lastNDays(days)) {
      result[day] = getTotalMlForDay(day);
    }
    return result;
  }

  Map<DateTime, int> getCurrentWeekTotals() {
    final result = <DateTime, int>{};
    for (final day in AppDateUtils.currentWeekDays()) {
      result[day] = getTotalMlForDay(day);
    }
    return result;
  }

  Map<DateTime, int> getCurrentMonthTotals() {
    final result = <DateTime, int>{};
    for (final day in AppDateUtils.currentMonthDays()) {
      result[day] = getTotalMlForDay(day);
    }
    return result;
  }

  int getTotalAllTime() =>
      _box.values.fold(0, (sum, e) => sum + e.amountMl);

  List<DateTime> getDaysWithAnyIntake() => _box.values
      .map((e) => AppDateUtils.startOfDay(e.timestamp))
      .toSet()
      .toList();
}
