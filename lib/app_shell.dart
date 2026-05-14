import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/home/providers/intake_provider.dart';
import 'features/home/providers/streak_provider.dart';
import 'core/providers/time_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime _lastKnownDate = DateTime.now();

  static const _screens = [
    HomeScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final n = DateTime.now();
    _lastKnownDate = DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResume();
    }
  }

  void _onAppResume() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today.isAfter(_lastKnownDate)) {
      _lastKnownDate = today;
      ref.read(currentDateProvider.notifier).state = today;
    }
    ref.read(todayIntakesProvider.notifier).reload();
    ref.read(streakProvider.notifier).recalculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.water_drop_outlined,
                  iconSelected: Icons.water_drop,
                  label: s.navToday,
                  selected: currentIndex == 0,
                  onTap: () => onTap(0)),
              _NavItem(
                  icon: Icons.calendar_month_outlined,
                  iconSelected: Icons.calendar_month,
                  label: s.navActivity,
                  selected: currentIndex == 1,
                  onTap: () => onTap(1)),
              _NavItem(
                  icon: Icons.trending_up_outlined,
                  iconSelected: Icons.trending_up,
                  label: s.navInsights,
                  selected: currentIndex == 2,
                  onTap: () => onTap(2)),
              _NavItem(
                  icon: Icons.tune_outlined,
                  iconSelected: Icons.tune,
                  label: s.navSettings,
                  selected: currentIndex == 3,
                  onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconSelected,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: selected
            ? BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? iconSelected : icon,
              color: selected ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textHint,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
