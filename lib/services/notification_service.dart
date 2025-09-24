import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  print("DEBUG Background notification fired: ${response.payload}");
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print("DEBUG Using timezone: $timeZoneName");

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        print("DEBUG Notification tapped: ${resp.payload}");
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // ✅ Create channels explicitly
    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'test_channel',
        'Test Notifications',
        description: 'Debugging test notifications',
        importance: Importance.max,
      ));

      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'mentor_channel',
        'Mentor Nudges',
        description: 'Daily persuasive mentor reminders',
        importance: Importance.max,
      ));

      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'immediate_channel',
        'Immediate',
        description: 'Instant debug/test notifications',
        importance: Importance.max,
      ));
    }

    await _requestPermissions();
    await _ensureExactAlarmsAllowed();
  }

  static Future<void> _requestPermissions() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      print("DEBUG Notification permission: $granted");

      final exactGranted = await androidImpl.requestExactAlarmsPermission();
      print("DEBUG Exact alarm permission: $exactGranted");
    }

    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> _ensureExactAlarmsAllowed() async {
    final status = await Permission.scheduleExactAlarm.status;
    print("DEBUG Exact alarm permission: $status");
    if (status.isDenied) {
      await openAppSettings();
    }
  }

  /// Daily mentor nudges
  static Future<void> scheduleDailyNudges() async {
    for (int id = 1; id <= 4; id++) {
      await _notifications.cancel(id);
    }
    final reminders = [
      {
        "id": 1,
        "hour": 9,
        "minute": 0,
        "msg":
        "🌞 Good morning. Build YOUR dream, not someone else’s. Write your Big 3 now."
      },
      {
        "id": 2,
        "hour": 12,
        "minute": 30,
        "msg":
        "🚨 Half the day is gone. Stop drifting — finish ONE important task right now."
      },
      {
        "id": 3,
        "hour": 16,
        "minute": 0,
        "msg":
        "🔥 Afternoon slump time. Winners push through. Open your Big 3 and act."
      },
      {
        "id": 4,
        "hour": 20,
        "minute": 0,
        "msg":
        "🌙 Tonight ends with pride or regret. Do ONE more task before you sleep."
      },
    ];

    for (final r in reminders) {
      final scheduled =
      _nextInstanceOfTime(r["hour"] as int, r["minute"] as int);
      print("DEBUG scheduling nudge ${r["id"]} at $scheduled");

      await _notifications.zonedSchedule(
        r["id"] as int,
        "Your Mentor",
        r["msg"] as String,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            "mentor_channel",
            "Mentor Nudges",
            channelDescription: "Daily persuasive mentor reminders",
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
  static Future<void> debugImmediateOnly() async {
    // Cancel everything first
    await _notifications.cancelAll();
    print("DEBUG cleared all pending notifications");

    // Force a fresh channel
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'immediate_test_channel',
        'Immediate Test',
        description: 'Fresh channel just for immediate test',
        importance: Importance.max,
      ));
    }

    // Now fire immediately
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "🚀 Immediate Test",
      "If you see this, notifications are working",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "immediate_test_channel",
          "Immediate Test",
          channelDescription: "Fresh channel just for immediate test",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    print("DEBUG fired immediate test notification");
  }

  /// 10-second debug notification
  static Future<void> scheduleTenSecondTest() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(seconds: 10));
    print("DEBUG scheduling 10s test for $scheduled");

    await _notifications.zonedSchedule(
      555,
      "⏰ 10s Test",
      "This should fire in 10 seconds!",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "test_channel",
          "Test Notifications",
          channelDescription: "Debugging short test",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    final pendings = await _notifications.pendingNotificationRequests();
    print("DEBUG pending scheduled: ${pendings.map((p) => p.id)}");

    // Also show immediate as foreground fallback
    await showNow("Immediate Fallback", "Foreground test fired instantly");
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> showNow(String title, String body) async {
    print("DEBUG calling showNow()");
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "immediate_channel", // must match created channel
          "Immediate",
          channelDescription: "Instant debug/test notifications",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
