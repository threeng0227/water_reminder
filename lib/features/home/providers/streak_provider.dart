import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/intake_repository.dart';
import '../../../core/utils/date_utils.dart';

final streakProvider = StateNotifierProvider<StreakNotifier, int>((ref) {
  return StreakNotifier(ref.read(intakeRepositoryFromProvider));
});

// Separate read-only provider to avoid circular dependency
final intakeRepositoryFromProvider = Provider<IntakeRepository>((ref) {
  return IntakeRepository();
});

class StreakNotifier extends StateNotifier<int> {
  final IntakeRepository _repo;

  StreakNotifier(this._repo) : super(0) {
    recalculate();
  }

  void recalculate() {
    final days = _repo.getDaysWithAnyIntake();
    state = AppDateUtils.currentStreakFrom(days);
  }
}
