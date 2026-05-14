import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 3)
class Achievement extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String icon;

  @HiveField(4)
  late bool isUnlocked;

  @HiveField(5)
  DateTime? unlockedAt;

  @HiveField(6)
  late int requiredValue;

  @HiveField(7)
  late String type; // 'streak', 'total_intake', 'daily_goal'

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

final defaultAchievements = [
  Achievement(id: 'first_drop', title: 'First Drop', description: 'Log your first water intake', icon: '💧', requiredValue: 1, type: 'total_intake'),
  Achievement(id: 'week_warrior', title: 'Week Warrior', description: 'Achieve a 7-day streak', icon: '🔥', requiredValue: 7, type: 'streak'),
  Achievement(id: 'month_master', title: 'Month Master', description: 'Achieve a 30-day streak', icon: '🏆', requiredValue: 30, type: 'streak'),
  Achievement(id: 'century', title: 'Century', description: 'Log 100 intake entries', icon: '💯', requiredValue: 100, type: 'total_intake'),
  Achievement(id: 'goal_crusher', title: 'Goal Crusher', description: 'Meet your daily goal 7 times', icon: '🎯', requiredValue: 7, type: 'daily_goal'),
  Achievement(id: 'hydration_hero', title: 'Hydration Hero', description: 'Achieve a 365-day streak', icon: '🌟', requiredValue: 365, type: 'streak'),
  Achievement(id: 'big_drinker', title: 'Big Drinker', description: 'Drink 3L in a single day', icon: '🫗', requiredValue: 3000, type: 'single_day'),
];
