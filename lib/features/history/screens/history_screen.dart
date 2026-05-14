import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatter.dart';
import '../../../data/repositories/intake_repository.dart';
import '../../../data/models/water_intake.dart';
import '../../settings/providers/settings_provider.dart';
import '../../home/providers/intake_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    ref.watch(todayIntakesProvider);
    final repo = IntakeRepository();
    final allIntakes = repo.getAll();

    final Map<DateTime, List<WaterIntake>> grouped = {};
    for (final intake in allIntakes) {
      final day = AppDateUtils.startOfDay(intake.timestamp);
      grouped.putIfAbsent(day, () => []).add(intake);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(s.activityTitle),
        backgroundColor: AppColors.background,
      ),
      body: days.isEmpty
          ? _emptyState(s)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final dayIntakes = grouped[day]!;
                final total = dayIntakes.fold(0, (sum, e) => sum + e.amountMl);
                final progress =
                    (total / settings.dailyGoalMl).clamp(0.0, 1.0);
                final isGoalMet = total >= settings.dailyGoalMl;

                return _DayCard(
                  day: day,
                  intakes: dayIntakes,
                  total: total,
                  goal: settings.dailyGoalMl,
                  progress: progress,
                  isGoalMet: isGoalMet,
                  s: s,
                );
              },
            ),
    );
  }

  Widget _emptyState(AppStrings s) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop_outlined,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              s.startYourJourney,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.historyEmptySubtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  final List<WaterIntake> intakes;
  final int total;
  final int goal;
  final double progress;
  final bool isGoalMet;
  final AppStrings s;

  const _DayCard({
    required this.day,
    required this.intakes,
    required this.total,
    required this.goal,
    required this.progress,
    required this.isGoalMet,
    required this.s,
  });

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayDetailSheet(
        day: day,
        intakes: intakes,
        total: total,
        goal: goal,
        isGoalMet: isGoalMet,
        s: s,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isGoalMet
                ? AppColors.success.withAlpha(60)
                : AppColors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.relativeDay(day,
                            todayLabel: s.today,
                            yesterdayLabel: s.yesterday),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d').format(day),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatter.mlToDisplay(total),
                          style: TextStyle(
                            color: isGoalMet
                                ? AppColors.success
                                : AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        if (isGoalMet)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${s.entries(intakes.length)} · ${Formatter.mlToDisplay(goal)}',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isGoalMet ? AppColors.success : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final DateTime day;
  final List<WaterIntake> intakes;
  final int total;
  final int goal;
  final bool isGoalMet;
  final AppStrings s;

  const _DayDetailSheet({
    required this.day,
    required this.intakes,
    required this.total,
    required this.goal,
    required this.isGoalMet,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.relativeDay(day,
                            todayLabel: s.today,
                            yesterdayLabel: s.yesterday),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(day),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatter.mlToDisplay(total),
                      style: TextStyle(
                        color: isGoalMet ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      s.ofGoal(Formatter.mlToDisplay(goal)),
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (total / goal).clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isGoalMet ? AppColors.success : AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: intakes.length,
              itemBuilder: (context, index) {
                final intake = intakes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          Formatter.mlToDisplay(intake.amountMl),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(intake.timestamp),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.of(context).padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(s.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
