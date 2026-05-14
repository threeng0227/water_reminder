class Formatter {
  static String mlToDisplay(int ml) {
    if (ml >= 1000) {
      final liters = ml / 1000;
      return '${liters.toStringAsFixed(liters % 1 == 0 ? 0 : 1)}L';
    }
    return '${ml}ml';
  }

  static String percentage(int current, int goal) {
    final pct = (current / goal * 100).clamp(0, 100).round();
    return '$pct%';
  }

  static String cupsCount(int totalMl, int cupSizeMl) {
    final cups = (totalMl / cupSizeMl);
    return cups.toStringAsFixed(cups % 1 == 0 ? 0 : 1);
  }
}
