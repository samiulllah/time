import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'notification_service.dart';

class AlarmManagerService {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> scheduleDynamicSummaries() async {
    await AndroidAlarmManager.cancel(200);
    await AndroidAlarmManager.cancel(201);

    // Daily at 10 PM
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      200,
      sendDailySummary,
      startAt: _todayAt(22, 0),
      exact: true,
      wakeup: true,
    );

    // Weekly at Sunday 8 PM
    await AndroidAlarmManager.periodic(
      const Duration(days: 7),
      201,
      sendWeeklySummary,
      startAt: _nextSundayAt(20, 0),
      exact: true,
      wakeup: true,
    );
  }
}

/// Top-level callbacks (must be top-level for AlarmManager)
void sendDailySummary() async {
  await NotificationService.showNow(
      "📊 Daily Report",
      "End of the day check-in: Did you own your time, or give it away? Tomorrow, protect your Big 3."
  );
}

void sendWeeklySummary() async {
  await NotificationService.showNow(
      "📅 Weekly Review",
      "This week’s done. Did you build YOUR life, or waste it on distractions? Next week is a reset."
  );
}

/// Helpers
DateTime _todayAt(int hour, int minute) {
  final now = DateTime.now();
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

DateTime _nextSundayAt(int hour, int minute) {
  DateTime scheduled = _todayAt(hour, minute);
  while (scheduled.weekday != DateTime.sunday) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
