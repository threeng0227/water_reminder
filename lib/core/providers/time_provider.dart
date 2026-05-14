import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticks every 60 seconds — used for live "X minutes ago" timestamps.
final timeTickProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  while (true) {
    await Future.delayed(const Duration(minutes: 1));
    yield DateTime.now();
  }
});

/// Current calendar date (year/month/day only). Changes at midnight.
final currentDateProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});
