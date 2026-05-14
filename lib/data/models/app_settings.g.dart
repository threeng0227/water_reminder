// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      dailyGoalMl: fields[0] as int,
      defaultCupSizeMl: fields[1] as int,
      notificationsEnabled: fields[2] as bool,
      smartReminders: fields[3] as bool,
      reminderIntervalMinutes: fields[4] as int,
      wakeHour: fields[5] as int,
      sleepHour: fields[6] as int,
      isPremium: fields[7] as bool,
      selectedTheme: fields[8] as String,
      customCupSizes: (fields[9] as List).cast<int>(),
      motivationalNotifications: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.dailyGoalMl)
      ..writeByte(1)
      ..write(obj.defaultCupSizeMl)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.smartReminders)
      ..writeByte(4)
      ..write(obj.reminderIntervalMinutes)
      ..writeByte(5)
      ..write(obj.wakeHour)
      ..writeByte(6)
      ..write(obj.sleepHour)
      ..writeByte(7)
      ..write(obj.isPremium)
      ..writeByte(8)
      ..write(obj.selectedTheme)
      ..writeByte(9)
      ..write(obj.customCupSizes)
      ..writeByte(10)
      ..write(obj.motivationalNotifications);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
