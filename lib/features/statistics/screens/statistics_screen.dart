import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import '../../../widgets/stat_card.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final stats = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(s.insightsTitle),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: s.thisWeek),
            Tab(text: s.thisMonth),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _WeekView(stats: stats, s: s),
          _MonthView(stats: stats, s: s),
        ],
      ),
    );
  }
}

List<Widget> _buildBottomSection(StatisticsData stats, AppStrings s) => [
      const SizedBox(height: 20),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          StatCard(
            label: s.dailyAverage,
            value: Formatter.mlToDisplay(stats.weeklyAvgMl),
            icon: Icons.show_chart_rounded,
            color: AppColors.primary,
          ),
          StatCard(
            label: s.bestStreak,
            value: s.streakDays(stats.bestStreak),
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFFF6B35),
          ),
          StatCard(
            label: s.goalsHit,
            value: '${stats.weeklyGoalDays}/${stats.weekDaysPassed}',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
          StatCard(
            label: s.onAStreak,
            value: s.streakDays(stats.currentStreak),
            icon: Icons.bolt_outlined,
            color: AppColors.accent,
          ),
        ],
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Text('🌊', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.allTimeTotal,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  Formatter.mlToDisplay(stats.totalAllTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _AchievementsSection(s: s),
    ];

class _WeekView extends StatelessWidget {
  final StatisticsData stats;
  final AppStrings s;
  const _WeekView({required this.stats, required this.s});

  @override
  Widget build(BuildContext context) {
    final days = stats.weeklyTotals.keys.toList()..sort();
    final values = days.map((d) => stats.weeklyTotals[d]!.toDouble()).toList();
    final maxVal = values.isEmpty
        ? stats.goalMl.toDouble()
        : values
            .reduce((a, b) => a > b ? a : b)
            .clamp(stats.goalMl.toDouble(), double.infinity);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ChartCard(
          title: s.thisWeek,
          child: SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: stats.goalMl / 2,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('E').format(days[idx]),
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(days.length, (i) {
                  final val = values[i];
                  final met = val >= stats.goalMl;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val == 0 ? 0.5 : val,
                        width: 28,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: met
                              ? [AppColors.success, const Color(0xFF81C784)]
                              : [AppColors.primary, AppColors.accent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: stats.goalMl.toDouble(),
                      color: AppColors.warning.withAlpha(160),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                            color: AppColors.warning, fontSize: 10),
                        labelResolver: (_) =>
                            s.goalLine(Formatter.mlToDisplay(stats.goalMl)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ..._buildBottomSection(stats, s),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  final StatisticsData stats;
  final AppStrings s;
  const _MonthView({required this.stats, required this.s});

  @override
  Widget build(BuildContext context) {
    final days = stats.monthlyTotals.keys.toList()..sort();
    final values = days.map((d) => stats.monthlyTotals[d]!.toDouble()).toList();
    final maxVal = values.isEmpty
        ? stats.goalMl.toDouble()
        : values
            .reduce((a, b) => a > b ? a : b)
            .clamp(stats.goalMl.toDouble(), double.infinity);

    bool showLabel(int idx) {
      if (idx < 0 || idx >= days.length) return false;
      final d = days[idx].day;
      return d == 1 || d == 8 || d == 15 || d == 22 || d == 29;
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ChartCard(
          title: s.thisMonth,
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxVal * 1.25,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: stats.goalMl / 2,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (!showLabel(idx)) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('d').format(days[idx]),
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: stats.goalMl.toDouble(),
                      color: AppColors.warning.withAlpha(160),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                            color: AppColors.warning, fontSize: 10),
                        labelResolver: (_) =>
                            s.goalLine(Formatter.mlToDisplay(stats.goalMl)),
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      days.length,
                      (i) => FlSpot(i.toDouble(), values[i]),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) {
                        final met = spot.y >= stats.goalMl;
                        return FlDotCirclePainter(
                          radius: 3,
                          color: met ? AppColors.success : AppColors.primary,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(80),
                          AppColors.primary.withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ..._buildBottomSection(stats, s),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      );
}

class _AchievementsSection extends StatelessWidget {
  final AppStrings s;
  const _AchievementsSection({required this.s});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _AchievementItem(s.ach1Title, s.ach1Desc, '💧', true),
      _AchievementItem(s.ach2Title, s.ach2Desc, '🔥', false),
      _AchievementItem(s.ach3Title, s.ach3Desc, '🏆', false),
      _AchievementItem(s.ach4Title, s.ach4Desc, '💯', false),
      _AchievementItem(s.ach5Title, s.ach5Desc, '🌟', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.achievementsTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map((a) => _AchievementTile(item: a, unlockedLabel: s.unlocked)),
      ],
    );
  }
}

class _AchievementItem {
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  _AchievementItem(this.title, this.description, this.icon, this.unlocked);
}

class _AchievementTile extends StatelessWidget {
  final _AchievementItem item;
  final String unlockedLabel;
  const _AchievementTile({required this.item, required this.unlockedLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.unlocked
              ? AppColors.primary.withAlpha(80)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: item.unlocked
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (item.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unlockedLabel,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Icon(Icons.lock_outline, color: AppColors.textHint, size: 18),
        ],
      ),
    );
  }
}
