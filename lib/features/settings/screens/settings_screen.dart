import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../services/ad_service.dart';
import '../../../services/notification_service.dart';
import '../providers/reminder_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/goal_picker_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final reminders = ref.watch(remindersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(s.settingsTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _NotificationPermissionBanner(),
          const SizedBox(height: 16),

          _SectionHeader(s.remindersSection),
          _SettingCard(
            children: [
              _ToggleTile(
                icon: '🔔',
                title: s.smartReminders,
                subtitle: s.smartRemindersSubtitle,
                value: settings.smartReminders,
                onChanged: (v) async {
                  if (v) {
                    final granted =
                        await NotificationService().requestPermissions();
                    if (!granted) return;
                  }
                  final updated = _copySettings(settings, smartReminders: v);
                  ref.read(settingsProvider.notifier).save(updated);
                },
              ),
              if (settings.smartReminders) ...[
                const Divider(color: AppColors.divider, height: 1),
                _SliderTile(
                  title: s.everyXMinutes(settings.reminderIntervalMinutes),
                  subtitle: s.reminderIntervalLabel,
                  value: settings.reminderIntervalMinutes.toDouble(),
                  min: 30,
                  max: 180,
                  divisions: 10,
                  onChanged: (v) {
                    final updated = _copySettings(settings,
                        reminderIntervalMinutes: v.toInt());
                    ref.read(settingsProvider.notifier).save(updated);
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                _TimeTile(
                  title: s.wakeTime,
                  hour: settings.wakeHour,
                  onChanged: (h) {
                    final updated = _copySettings(settings, wakeHour: h);
                    ref.read(settingsProvider.notifier).save(updated);
                  },
                ),
                const Divider(color: AppColors.divider, height: 1),
                _TimeTile(
                  title: s.sleepTime,
                  hour: settings.sleepHour,
                  onChanged: (h) {
                    final updated = _copySettings(settings, sleepHour: h);
                    ref.read(settingsProvider.notifier).save(updated);
                  },
                ),
              ],
              const Divider(color: AppColors.divider, height: 1),
              _ToggleTile(
                icon: '💬',
                title: s.encouragingMessages,
                subtitle: s.encouragingMessagesSubtitle,
                value: settings.motivationalNotifications,
                onChanged: (v) {
                  final updated = _copySettings(settings,
                      motivationalNotifications: v);
                  ref.read(settingsProvider.notifier).save(updated);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.myReminders,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddReminderDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text(s.add),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reminders.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  s.noRemindersYet,
                  style: const TextStyle(color: AppColors.textHint),
                ),
              ),
            )
          else
            ...reminders.map(
              (r) => ReminderTile(
                reminder: r,
                onToggle: (enabled) =>
                    ref.read(remindersProvider.notifier).toggle(r.id, enabled),
                onDelete: () =>
                    ref.read(remindersProvider.notifier).delete(r.id),
              ),
            ),

          const SizedBox(height: 20),
          _SectionHeader(s.yourGoalSection),
          _SettingCard(
            children: [
              _TapTile(
                icon: '🎯',
                title: s.dailyTarget,
                trailing: Formatter.mlToDisplay(settings.dailyGoalMl),
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => GoalPickerSheet(
                    currentGoal: settings.dailyGoalMl,
                    onSave: (ml) => ref
                        .read(settingsProvider.notifier)
                        .save(_copySettings(settings, dailyGoalMl: ml)),
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              _TapTile(
                icon: '🥤',
                title: s.defaultCup,
                trailing: Formatter.mlToDisplay(settings.defaultCupSizeMl),
                onTap: () => _showCupSizePicker(context, ref, settings),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _SectionHeader(s.languageSection),
          _SettingCard(
            children: [
              _LangTile(
                flag: '🇺🇸',
                label: s.langEnglish,
                selected: ref.watch(localeProvider) == 'en',
                onTap: () =>
                    ref.read(localeProvider.notifier).setLocale('en'),
              ),
              const Divider(color: AppColors.divider, height: 1),
              _LangTile(
                flag: '🇻🇳',
                label: s.langVietnamese,
                selected: ref.watch(localeProvider) == 'vi',
                onTap: () =>
                    ref.read(localeProvider.notifier).setLocale('vi'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _SectionHeader(s.premiumSection),
          _SettingCard(
            children: [
              if (settings.isPremium)
                _InfoTile(
                  icon: '✨',
                  title: s.premiumActive,
                  subtitle: s.premiumActiveSubtitle,
                  color: const Color(0xFFFFD700),
                )
              else
                _TapTile(
                  icon: '⭐',
                  title: s.goPremium,
                  subtitle: s.goPremiumSubtitle,
                  trailing: s.watchAd,
                  onTap: () => _showRewardedAd(context, ref, s),
                ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref) async {
    final granted = await NotificationService().areNotificationsEnabled();
    if (!granted && context.mounted) {
      await NotificationService().requestPermissions();
      final nowGranted = await NotificationService().areNotificationsEnabled();
      if (!nowGranted) return;
    }
    if (!context.mounted) return;
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    ref.read(remindersProvider.notifier).addReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
  }

  void _showCupSizePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Cup Size',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppConstants.presetCupSizes.map((ml) {
                final selected = ml == settings.defaultCupSizeMl;
                return GestureDetector(
                  onTap: () {
                    ref.read(settingsProvider.notifier).save(
                          _copySettings(settings, defaultCupSizeMl: ml),
                        );
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
                        color: selected
                            ? AppColors.background
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRewardedAd(BuildContext context, WidgetRef ref, s) async {
    final shown = await AdService().showRewarded(
      onReward: (ad, reward) {
        ref.read(settingsProvider.notifier).setPremium(true);
      },
    );
    if (!shown && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(s.adNotReady,
              style: const TextStyle(color: AppColors.textPrimary)),
          content: Text(s.adNotReadyMessage,
              style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.ok,
                  style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }

  AppSettings _copySettings(
    AppSettings s, {
    int? dailyGoalMl,
    int? defaultCupSizeMl,
    bool? notificationsEnabled,
    bool? smartReminders,
    int? reminderIntervalMinutes,
    int? wakeHour,
    int? sleepHour,
    bool? isPremium,
    String? selectedTheme,
    List<int>? customCupSizes,
    bool? motivationalNotifications,
  }) =>
      AppSettings(
        dailyGoalMl: dailyGoalMl ?? s.dailyGoalMl,
        defaultCupSizeMl: defaultCupSizeMl ?? s.defaultCupSizeMl,
        notificationsEnabled: notificationsEnabled ?? s.notificationsEnabled,
        smartReminders: smartReminders ?? s.smartReminders,
        reminderIntervalMinutes:
            reminderIntervalMinutes ?? s.reminderIntervalMinutes,
        wakeHour: wakeHour ?? s.wakeHour,
        sleepHour: sleepHour ?? s.sleepHour,
        isPremium: isPremium ?? s.isPremium,
        selectedTheme: selectedTheme ?? s.selectedTheme,
        customCupSizes: customCupSizes ?? s.customCupSizes,
        motivationalNotifications:
            motivationalNotifications ?? s.motivationalNotifications,
      );
}

// ── Reusable setting widgets ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(children: children),
      );
}

class _ToggleTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12))
            : null,
        trailing: Switch(value: value, onChanged: onChanged),
      );
}

class _TapTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _TapTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          ],
        ),
      );
}

class _SliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      );
}

class _TimeTile extends StatelessWidget {
  final String title;
  final int hour;
  final ValueChanged<int> onChanged;

  const _TimeTile({
    required this.title,
    required this.hour,
    required this.onChanged,
  });

  String get _formattedHour {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:00 $period';
  }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Text('⏰', style: TextStyle(fontSize: 22)),
        title: Text(title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        trailing: GestureDetector(
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: hour, minute: 0),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme:
                      const ColorScheme.dark(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (t != null) onChanged(t.hour);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formattedHour,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Text(flag, style: const TextStyle(fontSize: 22)),
        title: Text(label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        trailing: selected
            ? const Icon(Icons.check_rounded,
                color: AppColors.primary, size: 20)
            : null,
      );
}

class _NotificationPermissionBanner extends StatefulWidget {
  const _NotificationPermissionBanner();

  @override
  State<_NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends State<_NotificationPermissionBanner> with WidgetsBindingObserver {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final ok = await NotificationService().areNotificationsEnabled();
    if (mounted) setState(() => _granted = ok);
  }

  Future<void> _request() async {
    await NotificationService().requestPermissions();
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    if (_granted == null || _granted == true) return const SizedBox.shrink();
    // Read strings from the nearest Consumer — use a Consumer widget here
    return Consumer(
      builder: (context, ref, _) {
        final s = ref.watch(stringsProvider);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withAlpha(25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF6B35).withAlpha(80)),
          ),
          child: Row(
            children: [
              const Text('🔕', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.notificationsDisabled,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.notificationsDisabledSubtitle,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _request,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s.enableNotifications,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(title,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      );
}
