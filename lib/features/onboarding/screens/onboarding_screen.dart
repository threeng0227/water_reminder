import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/formatter.dart';
import '../../../data/models/app_settings.dart';
import '../../../app_shell.dart';
import '../../settings/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedGoal = 2000;

  // page 0 = language, pages 1-3 = info, page 4 = goal
  static const _infoCount = 3;
  static const _totalPages = _infoCount + 2; // language + info + goal

  bool get _isLanguagePage => _currentPage == 0;
  bool get _isGoalPage => _currentPage == _totalPages - 1;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only on info pages)
            if (!_isLanguagePage && !_isGoalPage)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    s.skip,
                    style: const TextStyle(color: AppColors.textHint),
                  ),
                ),
              )
            else
              const SizedBox(height: 8),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildLanguagePage(s),
                  _buildInfoPage(s.ob1Title, s.ob1Subtitle, '💧'),
                  _buildInfoPage(s.ob2Title, s.ob2Subtitle, '🔔'),
                  _buildInfoPage(s.ob3Title, s.ob3Subtitle, '📊'),
                  _buildGoalPage(s),
                ],
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGoalPage ? _finish : _nextPage,
                  child: Text(
                    _isGoalPage
                        ? s.getStarted
                        : _isLanguagePage
                            ? s.continueBtn
                            : s.next,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage(AppStrings s) {
    final currentLocale = ref.watch(localeProvider);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌐', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 32),
          Text(
            s.chooseLanguage,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.languageSubtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _LangOption(
            flag: '🇺🇸',
            label: 'English',
            selected: currentLocale == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale('en'),
          ),
          const SizedBox(height: 16),
          _LangOption(
            flag: '🇻🇳',
            label: 'Tiếng Việt',
            selected: currentLocale == 'vi',
            onTap: () => ref.read(localeProvider.notifier).setLocale('vi'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage(String title, String subtitle, String emoji) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          Text(
            s.setGoalTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.setGoalSubtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            Formatter.mlToDisplay(_selectedGoal),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedGoal.toDouble(),
            min: 500,
            max: 5000,
            divisions: 45,
            onChanged: (v) => setState(() => _selectedGoal = v.round()),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _GoalChip(label: '1.5L', value: 1500, selected: _selectedGoal == 1500, onTap: () => setState(() => _selectedGoal = 1500)),
              _GoalChip(label: '2L', value: 2000, selected: _selectedGoal == 2000, onTap: () => setState(() => _selectedGoal = 2000)),
              _GoalChip(label: '2.5L', value: 2500, selected: _selectedGoal == 2500, onTap: () => setState(() => _selectedGoal = 2500)),
              _GoalChip(label: '3L', value: 3000, selected: _selectedGoal == 3000, onTap: () => setState(() => _selectedGoal = 3000)),
            ],
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).save(
          AppSettings(
            dailyGoalMl: _selectedGoal,
            defaultCupSizeMl: settings.defaultCupSizeMl,
            notificationsEnabled: settings.notificationsEnabled,
            smartReminders: settings.smartReminders,
            reminderIntervalMinutes: settings.reminderIntervalMinutes,
            wakeHour: settings.wakeHour,
            sleepHour: settings.sleepHour,
            isPremium: settings.isPremium,
            selectedTheme: settings.selectedTheme,
            customCupSizes: settings.customCupSizes,
            motivationalNotifications: settings.motivationalNotifications,
          ),
        );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onComplete();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    }
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(30)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
