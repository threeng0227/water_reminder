import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late int hour;

  @HiveField(2)
  late int minute;

  @HiveField(3)
  late bool isEnabled;

  @HiveField(4)
  late List<bool> weekdays; // index 0=Mon, 6=Sun

  @HiveField(5)
  late String label;

  Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    List<bool>? weekdays,
    this.label = 'Drink Water',
  }) : weekdays = weekdays ?? List.filled(7, true);

  String get timeString {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
