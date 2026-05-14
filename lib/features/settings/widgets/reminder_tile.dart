import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/reminder.dart';

class ReminderTile extends ConsumerWidget {
  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(stringsProvider).weekdayLabels;
    final activeDays = reminder.weekdays
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => labels[e.key])
        .join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reminder.isEnabled
              ? AppColors.primary.withAlpha(60)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(
            reminder.timeString,
            style: TextStyle(
              color: reminder.isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textHint,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  activeDays,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: reminder.isEnabled, onChanged: onToggle),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: AppColors.textHint, size: 20),
          ),
        ],
      ),
    );
  }
}
