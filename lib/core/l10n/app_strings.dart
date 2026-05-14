class AppStrings {
  final String locale;
  const AppStrings(this.locale);

  bool get _vi => locale == 'vi';

  // ── General ───────────────────────────────────────────────────────────────
  String get appName => _vi ? 'Nhắc Uống Nước' : 'Hydrate';
  String get ok => 'OK';
  String get close => _vi ? 'Đóng' : 'Close';
  String get skip => _vi ? 'Bỏ qua' : 'Skip';
  String get next => _vi ? 'Tiếp theo' : 'Next';
  String get save => _vi ? 'Lưu' : 'Save';
  String get add => _vi ? 'Thêm' : 'Add';
  String get cancel => _vi ? 'Hủy' : 'Cancel';

  // ── Splash ────────────────────────────────────────────────────────────────
  String get splashTagline =>
      _vi ? 'Người bạn uống nước mỗi ngày' : 'Your daily hydration companion';

  // ── Language selector ─────────────────────────────────────────────────────
  String get chooseLanguage => _vi ? 'Chọn ngôn ngữ' : 'Choose your language';
  String get languageSubtitle =>
      _vi ? 'Bạn có thể thay đổi sau trong Cài đặt' : 'You can change this later in Settings';
  String get continueBtn => _vi ? 'Tiếp tục' : 'Continue';

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get ob1Title => _vi ? 'Uống đủ nước' : 'Stay Hydrated';
  String get ob1Subtitle =>
      _vi ? 'Theo dõi lượng nước uống hàng ngày và hình thành thói quen lành mạnh.' : 'Track your daily water intake and build a healthy habit.';
  String get ob2Title => _vi ? 'Nhắc nhở thông minh' : 'Smart Reminders';
  String get ob2Subtitle =>
      _vi ? 'Không bao giờ quên uống nước với hệ thống nhắc nhở thông minh.' : 'Never forget to drink water with intelligent reminders.';
  String get ob3Title => _vi ? 'Theo dõi tiến trình' : 'Track Progress';
  String get ob3Subtitle =>
      _vi ? 'Xem chuỗi ngày, biểu đồ và thành tích của bạn.' : 'See your streaks, charts, and achievements.';
  String get setGoalTitle => _vi ? 'Đặt mục tiêu hàng ngày' : 'Set Your Daily Goal';
  String get setGoalSubtitle =>
      _vi ? 'Bạn muốn uống bao nhiêu nước mỗi ngày?' : 'How much water do you aim to drink each day?';
  String get getStarted => _vi ? 'Bắt đầu 🚀' : 'Get Started 🚀';

  // ── Bottom nav ────────────────────────────────────────────────────────────
  String get navToday => _vi ? 'Hôm nay' : 'Today';
  String get navActivity => _vi ? 'Lịch sử' : 'Activity';
  String get navInsights => _vi ? 'Thống kê' : 'Insights';
  String get navSettings => _vi ? 'Cài đặt' : 'Settings';

  // ── Home ──────────────────────────────────────────────────────────────────
  String get cups => _vi ? 'Ly' : 'Cups';
  String get lastSip => _vi ? 'Lần cuối' : 'Last sip';
  String get leftToGo => _vi ? 'Còn lại' : 'Left to go';
  String get logADrink => _vi ? 'Ghi nhận uống' : 'Log a Drink';
  String get todaysSips => _vi ? 'Hôm nay' : "Today's Sips";
  String get readyToHydrate => _vi ? 'Bắt đầu uống nước nào?' : 'Ready to hydrate?';
  String get tapCupToStart =>
      _vi ? 'Nhấn vào ly để ghi nhận lần đầu.' : 'Tap a cup above to log your first sip.';
  String get fullLog => _vi ? 'Toàn bộ' : 'Full Log';
  String get entryRemoved => _vi ? '🗑️ Đã xóa' : '🗑️ Entry removed';

  String addedToast(String amount) =>
      _vi ? '💧 +$amount đã thêm' : '💧 +$amount added';
  String entries(int count) =>
      _vi ? '$count lần' : '$count ${count == 1 ? 'entry' : 'entries'}';
  String viewAllEntries(int count) =>
      _vi ? 'Xem tất cả $count lần' : 'View all $count entries';
  String streakDays(int days) =>
      _vi ? '$days ngày' : '$days ${days == 1 ? 'day' : 'days'}';

  // ── Time relative ─────────────────────────────────────────────────────────
  String get justNow => _vi ? 'Vừa xong' : 'Just now';
  String minutesAgo(int m) => _vi ? '${m}ph trước' : '${m}m ago';
  String hoursAgo(int h) => _vi ? '${h}g trước' : '${h}h ago';

  // ── History ───────────────────────────────────────────────────────────────
  String get activityTitle => _vi ? 'Lịch sử' : 'Activity';
  String get startYourJourney => _vi ? 'Bắt đầu hành trình' : 'Start your journey';
  String get historyEmptySubtitle =>
      _vi ? 'Lịch sử uống nước sẽ hiển thị ở đây' : 'Your hydration history will appear here';
  String get today => _vi ? 'Hôm nay' : 'Today';
  String get yesterday => _vi ? 'Hôm qua' : 'Yesterday';
  String ofGoal(String goal) => _vi ? '/ $goal' : 'of $goal';

  // ── Statistics ────────────────────────────────────────────────────────────
  String get insightsTitle => _vi ? 'Thống kê' : 'Insights';
  String get thisWeek => _vi ? 'Tuần này' : 'This Week';
  String get thisMonth => _vi ? 'Tháng này' : 'This Month';
  String get dailyAverage => _vi ? 'Trung bình ngày' : 'Daily Average';
  String get bestStreak => _vi ? 'Chuỗi dài nhất' : 'Best Streak';
  String get goalsHit => _vi ? 'Đạt mục tiêu' : 'Goals Hit';
  String get onAStreak => _vi ? 'Chuỗi hiện tại' : 'On a Streak';
  String get allTimeTotal => _vi ? 'Tổng cộng' : 'All-Time Total';
  String get achievementsTitle => _vi ? 'Thành tích' : 'Achievements';
  String get unlocked => _vi ? 'Đã mở' : 'Unlocked';
  String goalLine(String amount) =>
      _vi ? 'Mục tiêu: $amount' : 'Goal: $amount';

  // Achievements
  String get ach1Title => _vi ? 'Giọt đầu tiên' : 'First Drop';
  String get ach1Desc => _vi ? 'Ghi nhận lần đầu' : 'Log first intake';
  String get ach2Title => _vi ? 'Chiến binh tuần' : 'Week Warrior';
  String get ach2Desc => _vi ? 'Chuỗi 7 ngày' : '7-day streak';
  String get ach3Title => _vi ? 'Chủ nhân tháng' : 'Month Master';
  String get ach3Desc => _vi ? 'Chuỗi 30 ngày' : '30-day streak';
  String get ach4Title => _vi ? 'Trăm lần' : 'Century';
  String get ach4Desc => _vi ? '100 lần ghi nhận' : '100 entries';
  String get ach5Title => _vi ? 'Anh hùng nước' : 'Hydration Hero';
  String get ach5Desc => _vi ? 'Chuỗi 365 ngày' : '365-day streak';

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settingsTitle => _vi ? 'Cài đặt' : 'Settings';
  String get remindersSection => _vi ? 'Nhắc nhở' : 'Reminders';
  String get smartReminders => _vi ? 'Nhắc nhở thông minh' : 'Smart Reminders';
  String get smartRemindersSubtitle =>
      _vi ? 'Nhắc nhẹ nhàng suốt cả ngày' : 'Gentle nudges throughout your day';
  String everyXMinutes(int m) =>
      _vi ? 'Mỗi $m phút' : 'Every $m minutes';
  String get reminderIntervalLabel => _vi ? 'Khoảng cách nhắc' : 'Reminder interval';
  String get wakeTime => _vi ? 'Giờ thức dậy' : 'Wake Time';
  String get sleepTime => _vi ? 'Giờ ngủ' : 'Sleep Time';
  String get encouragingMessages => _vi ? 'Tin nhắn động viên' : 'Encouraging Messages';
  String get encouragingMessagesSubtitle =>
      _vi ? 'Lời động viên kèm mỗi nhắc nhở' : 'Friendly words with each reminder';
  String get myReminders => _vi ? 'Nhắc nhở của tôi' : 'My Reminders';
  String get noRemindersYet =>
      _vi ? 'Chưa có nhắc nhở — thêm cái đầu tiên.' : 'No reminders yet — add your first.';
  String get yourGoalSection => _vi ? 'Mục tiêu' : 'Your Goal';
  String get dailyTarget => _vi ? 'Mục tiêu ngày' : 'Daily Target';
  String get defaultCup => _vi ? 'Ly mặc định' : 'Default Cup';
  String get premiumSection => 'Premium';
  String get premiumActive => _vi ? 'Đã là Premium' : 'Premium Active';
  String get premiumActiveSubtitle =>
      _vi ? 'Tất cả đã sẵn sàng — thưởng thức nhé.' : "You're all set — enjoy every drop.";
  String get goPremium => _vi ? 'Nâng cấp Premium' : 'Go Premium';
  String get goPremiumSubtitle =>
      _vi ? 'Xóa quảng cáo · mở khóa tất cả' : 'Remove ads · unlock all features';
  String get watchAd => _vi ? 'Xem quảng cáo' : 'Watch Ad';
  String get adNotReady => _vi ? 'Quảng cáo chưa sẵn' : 'Ad not ready';
  String get adNotReadyMessage => _vi ? 'Vui lòng thử lại sau.' : 'Please try again later.';
  String get languageSection => _vi ? 'Ngôn ngữ' : 'Language';
  String get notificationsDisabled => _vi ? 'Thông báo bị tắt' : 'Notifications Disabled';
  String get notificationsDisabledSubtitle =>
      _vi ? 'Nhắc nhở không hoạt động nếu không có quyền.' : "Reminders won't work without permission.";
  String get enableNotifications => _vi ? 'Bật' : 'Enable';

  // ── Add water sheet ───────────────────────────────────────────────────────
  String get addWaterTitle => _vi ? 'Ghi nhận nước uống' : 'Add Water Intake';
  String get customAmountHint => _vi ? 'Số ml tùy chỉnh' : 'Custom amount (ml)';
  String addAmountBtn(int ml) => _vi ? 'Thêm ${ml}ml' : 'Add ${ml}ml';

  // ── Goal picker ───────────────────────────────────────────────────────────
  String get setDailyGoalSheet => _vi ? 'Đặt mục tiêu ngày' : 'Set Daily Goal';
  String get saveGoal => _vi ? 'Lưu mục tiêu' : 'Save Goal';

  // ── Reminder tile weekdays ────────────────────────────────────────────────
  List<String> get weekdayLabels =>
      _vi ? ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'] : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ── Notifications ─────────────────────────────────────────────────────────
  String get notifTitle => _vi ? '💧 Đến giờ uống nước!' : '💧 Time to Hydrate!';
  String get notifChannelName => _vi ? 'Nhắc uống nước' : 'Water Reminders';
  String get notifChannelDesc =>
      _vi ? 'Nhắc nhở uống nước hàng ngày' : 'Reminders to drink water';

  List<String> get motivationalMessages => _vi
      ? [
          'Uống một ngụm — cơ thể sẽ cảm ơn bạn 💙',
          'Ngụm nhỏ, năng lượng lớn. Bạn làm được!',
          'Đến giờ uống nước rồi! Uống một ngụm đi nào.',
          'Não bộ có 73% là nước. Hãy giữ cho nó sắc bén.',
          'Một chút nước sẽ tạo ra sự khác biệt lớn.',
          'Tươi mát mãi. Là chính bạn.',
          'Cơ thể bạn đang cần nước đấy!',
          'Từng ngụm một, bạn đang làm rất tốt.',
          'Ngay cả nhà vô địch cũng dừng lại để uống nước.',
          'Uống ngay bây giờ, cảm thấy tuyệt vời sau đó.',
          'Da bạn đang rạng rỡ — hãy duy trì nhé.',
          'Thêm một ngụm, gần hơn đến mục tiêu.',
        ]
      : [
          "Take a sip — your body will thank you 💙",
          "Small sip, big energy. You've got this.",
          "Hydration check! Time for a quick drink.",
          "Your brain is 73% water. Keep it sharp.",
          "A little water goes a long way.",
          "Stay refreshed. Stay you.",
          "Your body called — it wants water.",
          "Sip by sip, you're doing great.",
          "Even champions pause to hydrate.",
          "Drink now, feel amazing later.",
          "Your skin is glowing — keep it up.",
          "One sip closer to your goal.",
        ];
}
