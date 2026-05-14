import 'package:home_widget/home_widget.dart';
import '../core/constants/app_constants.dart';

class WidgetService {
  static const _authorName = AppConstants.widgetAuthor;

  static Future<void> updateWidget({
    required int currentMl,
    required int goalMl,
    required int streak,
  }) async {
    await HomeWidget.saveWidgetData<int>('current_ml', currentMl);
    await HomeWidget.saveWidgetData<int>('goal_ml', goalMl);
    await HomeWidget.saveWidgetData<int>('streak', streak);
    await HomeWidget.saveWidgetData<String>(
      'percentage',
      '${(currentMl / goalMl * 100).clamp(0, 100).round()}%',
    );
    await HomeWidget.updateWidget(
      name: AppConstants.widgetName,
      androidName: AppConstants.widgetName,
      iOSName: AppConstants.widgetName,
      qualifiedAndroidName: '$_authorName.${AppConstants.widgetName}',
    );
  }
}
