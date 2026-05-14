import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/reminder.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../services/notification_service.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  return RemindersNotifier(ref.read(reminderRepositoryProvider));
});

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  final ReminderRepository _repo;

  RemindersNotifier(this._repo) : super(_repo.getAll());

  Future<void> addReminder({
    required int hour,
    required int minute,
    List<bool>? weekdays,
    String label = 'Drink Water',
  }) async {
    final r = await _repo.addReminder(
      hour: hour,
      minute: minute,
      weekdays: weekdays,
      label: label,
    );
    state = _repo.getAll();
    await NotificationService().scheduleReminder(r);
  }

  Future<void> toggle(String id, bool enabled) async {
    await _repo.toggleReminder(id, enabled);
    state = _repo.getAll();
    final r = state.firstWhere((r) => r.id == id);
    if (enabled) {
      await NotificationService().scheduleReminder(r);
    } else {
      await NotificationService().cancelReminder(id);
    }
  }

  Future<void> delete(String id) async {
    await _repo.deleteReminder(id);
    state = _repo.getAll();
    await NotificationService().cancelReminder(id);
  }
}
