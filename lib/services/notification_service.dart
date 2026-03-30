import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

await _plugin.initialize(
  settings: settings,
  onDidReceiveNotificationResponse:
      (NotificationResponse response) async {},
);
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.dueDate == null) return;

    final dueDate = task.dueDate!;
    final dueTime = task.dueTime;

    final scheduledDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime?.hour ?? 9,
      dueTime?.minute ?? 0,
    );

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_deadline_channel',
        'Task Deadlines',
        channelDescription: 'Notifications for upcoming task deadlines',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    final notifyTime =
        scheduledDate.subtract(Duration(minutes: task.remindBeforeMinutes));

    // 🔥 قبل 30 دقيقة
    if (notifyTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: task.id.hashCode % 100000,
        title: '⏰ Task Due Soon!',
        body: '"${task.title}" is due in 30 minutes!',
        scheduledDate: tz.TZDateTime.from(notifyTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 🔥 وقت التسليم
    if (scheduledDate.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: (task.id.hashCode + 1) % 100000,
        title: '🔔 Task Deadline!',
        body: '"${task.title}" is due now!',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    await _plugin.cancel(id: taskId.hashCode % 100000);
    await _plugin.cancel(id: (taskId.hashCode + 1) % 100000);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}