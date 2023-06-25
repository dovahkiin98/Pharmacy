import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const androidAlertsChannel = NotificationDetails(
  android: AndroidNotificationDetails(
    'alerts',
    'alerts',
    icon: "ic_notification",
    priority: Priority.max,
    importance: Importance.max,
    enableVibration: true,
  ),
);

initNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
  const initializationSettingsDarwin = DarwinInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );
}

void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {}

void onDidReceiveNotificationResponse(NotificationResponse details) {}
