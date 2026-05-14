import 'package:hive/hive.dart';

part 'water_intake.g.dart';

@HiveType(typeId: 0)
class WaterIntake extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime timestamp;

  @HiveField(2)
  late int amountMl;

  @HiveField(3)
  late String cupType;

  WaterIntake({
    required this.id,
    required this.timestamp,
    required this.amountMl,
    this.cupType = 'glass',
  });
}
