import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/time_provider.dart';
import '../../../services/notification_service.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../providers/intake_provider.dart';
import '../providers/streak_provider.dart';
import '../../../data/models/water_intake.dart';
import '../../../widgets/water_progress_ring.dart';
import '../../../widgets/cup_button.dart';
import '../../../widgets/banner_ad_widget.dart';
import '../widgets/intake_list_tile.dart';
import '../widgets/add_water_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _splashController;

  @override
  void initState() {
    super.initState();
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  void _addWater(int ml) {
    final s = ref.read(stringsProvider);
    ref.read(todayIntakesProvider.notifier).addIntake(ml);
    _splashController..reset()..forward();
    _showToast(s.addedToast(Formatter.mlToDisplay(ml)));
  }

  void _removeWater(String id) {
    final s = ref.read(stringsProvider);
    ref.read(todayIntakesProvider.notifier).removeIntake(id);
    _showToast(s.entryRemoved);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppColors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        elevation: 0,
      ),
    );
  }

  void _showFullLog(List<WaterIntake> intakes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FullLogSheet(
        intakes: intakes,
        onDelete: _removeWater,
      ),
    );
  }

  void _showCustomAmountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWaterBottomSheet(onAdd: _addWater),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final progress = ref.watch(dailyProgressProvider);
    final total = ref.watch(todayTotalMlProvider);
    final settings = ref.watch(settingsProvider);
    final streak = ref.watch(streakProvider);
    final intakes = ref.watch(todayIntakesProvider);
    final isPremium = settings.isPremium;
    // Watch time tick so "X minutes ago" updates every minute
    final now = ref.watch(timeTickProvider).maybeWhen(
          data: (t) => t,
          orElse: () => DateTime.now(),
        );

    final previewIntakes = intakes.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Sticky header (luôn hiện, không scroll) ───────────────────────
          _StickyHeader(streak: streak),

          // ── Nội dung scroll được ──────────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Progress ring
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: WaterProgressRing(
                        progress: progress,
                        currentMl: total,
                        goalMl: settings.dailyGoalMl,
                        size: 220,
                      ),
                    ),
                  ),
                ),

                // Stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _MiniStat(
                          icon: '🥤',
                          label: s.cups,
                          value: Formatter.cupsCount(
                              total, settings.defaultCupSizeMl),
                        ),
                        const SizedBox(width: 10),
                        _MiniStat(
                          icon: '⏱',
                          label: s.lastSip,
                          value: intakes.isEmpty
                              ? '—'
                              : _timeSince(intakes.first.timestamp, now, s),
                        ),
                        const SizedBox(width: 10),
                        _MiniStat(
                          icon: '💧',
                          label: s.leftToGo,
                          value: Formatter.mlToDisplay(
                            (settings.dailyGoalMl - total)
                                .clamp(0, settings.dailyGoalMl),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Quick-add cups — centered when items fit, scrollable when they don't
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final sizes = settings.customCupSizes;
                      const itemW = 76.0;
                      const gap = 10.0;
                      final totalW =
                          sizes.length * itemW + (sizes.length - 1) * gap;
                      final availableW = constraints.maxWidth - 40;
                      final hPad = totalW < availableW
                          ? (constraints.maxWidth - totalW) / 2
                          : 20.0;
                      return SizedBox(
                        height: 82,
                        child: ListView.separated(
                          padding:
                              EdgeInsets.symmetric(horizontal: hPad),
                          scrollDirection: Axis.horizontal,
                          itemCount: sizes.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(width: gap),
                          itemBuilder: (context, index) {
                            final size = sizes[index];
                            return CupButton(
                              amountMl: size,
                              icon: _cupIcon(size),
                              onTap: () => _addWater(size),
                              isSelected: size == settings.defaultCupSizeMl,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Log Water button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showCustomAmountSheet,
                        icon: const Icon(Icons.water_drop_outlined, size: 20),
                        label: Text(s.logADrink),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Today's Log header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.todaysSips,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (intakes.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showFullLog(intakes),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(60),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s.entries(intakes.length),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.expand_more_rounded,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                // Preview 3 entries gần nhất
                if (intakes.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => IntakeListTile(
                          intake: previewIntakes[index],
                          onDelete: () =>
                              _removeWater(previewIntakes[index].id),
                        ),
                        childCount: previewIntakes.length,
                      ),
                    ),
                  ),

                // "Xem tất cả" nếu có > 3 entries
                if (intakes.length > 3)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: GestureDetector(
                        onTap: () => _showFullLog(intakes),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.list_alt_rounded,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                s.viewAllEntries(intakes.length),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Empty state
                if (intakes.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 48,
                            color: AppColors.primary.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.readyToHydrate,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.tapCupToStart,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Banner ad
                if (!isPremium)
                  const SliverToBoxAdapter(child: BannerAdWidget()),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeSince(DateTime time, DateTime now, s) {
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return s.justNow;
    if (diff.inMinutes < 60) return s.minutesAgo(diff.inMinutes);
    return s.hoursAgo(diff.inHours);
  }

  IconData _cupIcon(int ml) {
    if (ml <= 150) return Icons.coffee_outlined;
    if (ml <= 250) return Icons.local_cafe_outlined;
    if (ml <= 350) return Icons.water_drop_outlined;
    if (ml <= 500) return Icons.sports_bar_outlined;
    return Icons.local_drink_outlined;
  }
}

// ── Sticky Header ─────────────────────────────────────────────────────────────

class _StickyHeader extends StatelessWidget {
  final int streak;
  const _StickyHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEEE').format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _StreakBadge(streak: streak),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full Log Bottom Sheet ─────────────────────────────────────────────────────

class _FullLogSheet extends ConsumerWidget {
  final List<WaterIntake> intakes;
  final void Function(String id) onDelete;

  const _FullLogSheet({required this.intakes, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final total = intakes.fold(0, (s, e) => s + e.amountMl);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.fullLog,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatter.mlToDisplay(total),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      s.entries(intakes.length),
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 4),

          // Danh sách đầy đủ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: intakes.length,
              itemBuilder: (context, index) {
                final intake = intakes[index];
                return IntakeListTile(
                  intake: intake,
                  onDelete: () {
                    onDelete(intake.id);
                    if (intakes.length == 1) Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          // Nút đóng
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StreakBadge extends ConsumerWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            s.streakDays(streak),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _MiniStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textHint, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

