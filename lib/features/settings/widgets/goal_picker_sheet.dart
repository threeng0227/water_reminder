import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/formatter.dart';

class GoalPickerSheet extends ConsumerStatefulWidget {
  final int currentGoal;
  final ValueChanged<int> onSave;

  const GoalPickerSheet({
    super.key,
    required this.currentGoal,
    required this.onSave,
  });

  @override
  ConsumerState<GoalPickerSheet> createState() => _GoalPickerSheetState();
}

class _GoalPickerSheetState extends ConsumerState<GoalPickerSheet> {
  late int _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.setDailyGoalSheet,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Formatter.mlToDisplay(_goal),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _goal.toDouble(),
            min: 500,
            max: 5000,
            divisions: 45,
            label: Formatter.mlToDisplay(_goal),
            onChanged: (v) => setState(() => _goal = v.round()),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [1500, 2000, 2500, 3000, 3500].map((ml) {
              return ActionChip(
                label: Text('$ml ml'),
                backgroundColor: ml == _goal
                    ? AppColors.primary.withAlpha(30)
                    : AppColors.surfaceVariant,
                side: BorderSide(
                  color: ml == _goal ? AppColors.primary : AppColors.divider,
                ),
                labelStyle: TextStyle(
                  color:
                      ml == _goal ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () => setState(() => _goal = ml),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(_goal);
              },
              child: Text(s.saveGoal),
            ),
          ),
        ],
      ),
    );
  }
}
