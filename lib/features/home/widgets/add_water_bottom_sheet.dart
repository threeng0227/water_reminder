import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../features/settings/providers/settings_provider.dart';

class AddWaterBottomSheet extends ConsumerStatefulWidget {
  final void Function(int ml) onAdd;

  const AddWaterBottomSheet({super.key, required this.onAdd});

  @override
  ConsumerState<AddWaterBottomSheet> createState() =>
      _AddWaterBottomSheetState();
}

class _AddWaterBottomSheetState extends ConsumerState<AddWaterBottomSheet> {
  late int _selectedMl;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMl = ref.read(settingsProvider).defaultCupSizeMl;
    _controller.text = _selectedMl.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            ref.watch(stringsProvider).addWaterTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),

          // Quick select chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: settings.customCupSizes.map((ml) {
              final selected = ml == _selectedMl;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMl = ml;
                    _controller.text = ml.toString();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    '$ml ml',
                    style: TextStyle(
                      color: selected ? AppColors.background : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Custom amount input
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
            decoration: InputDecoration(
              labelText: ref.watch(stringsProvider).customAmountHint,
              suffixText: 'ml',
              suffixStyle: const TextStyle(color: AppColors.textHint),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed > 0) {
                setState(() => _selectedMl = parsed);
              }
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onAdd(_selectedMl);
              },
              child: Text(ref.watch(stringsProvider).addAmountBtn(_selectedMl)),
            ),
          ),
        ],
      ),
    );
  }
}
