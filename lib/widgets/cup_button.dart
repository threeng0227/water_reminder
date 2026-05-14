import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CupButton extends StatefulWidget {
  final int amountMl;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const CupButton({
    super.key,
    required this.amountMl,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<CupButton> createState() => _CupButtonState();
}

class _CupButtonState extends State<CupButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.primaryGradient : null,
            color: widget.isSelected ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.divider,
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 24,
                color: widget.isSelected
                    ? AppColors.background
                    : AppColors.primary,
              ),
              const SizedBox(height: 6),
              Text(
                _label(widget.amountMl),
                style: TextStyle(
                  color: widget.isSelected
                      ? AppColors.background
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show "250ml", "1L" etc. compactly.
  String _label(int ml) {
    if (ml >= 1000 && ml % 1000 == 0) return '${ml ~/ 1000}L';
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
    return '${ml}ml';
  }
}
