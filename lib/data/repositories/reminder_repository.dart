import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../../core/constants/app_constants.dart';

class ReminderRepository {
  Box<Reminder> get _box =>
      Hive.box<Reminder>(AppConstants.hiveBoxReminders);

  List<Reminder> getAll() => _box.values.toList()
    ..sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });

  Future<Reminder> addReminder({
    required int hour,
    required int minute,
    List<bool>? weekdays,
    String label = 'Drink Water',
  }) async {
    final reminder = Reminder(
      id: const Uuid().v4(),
      hour: hour,
      minute: minute,
      weekdays: weekdays,
      label: label,
    );
    await _box.put(reminder.id, reminder);
    return reminder;
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _box.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final r = _box.get(id);
    if (r != null) {
      r.isEnabled = enabled;
      await _box.put(id, r);
    }
  }
}
