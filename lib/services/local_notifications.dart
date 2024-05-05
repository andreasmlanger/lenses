import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'local_time_zone.dart';
import 'package:lenses/services/local_storage.dart';
import 'package:lenses/services/notifications.dart';


Future<bool> isNotificationScheduled(notificationsPlugin, int id) async {
  final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
  return pendingNotifications.any((notification) => notification.id == id);
}

Future<List<bool>> getScheduledNotifications(notificationsPlugin) async {
  final n0 = await isNotificationScheduled(notificationsPlugin, 0);
  final n1 = await isNotificationScheduled(notificationsPlugin, 1);
  final n2 = await isNotificationScheduled(notificationsPlugin, 2);
  final n3 = await isNotificationScheduled(notificationsPlugin, 3);
  return [n0 || n1, n2, n3];
}

Future<void> cancelAllNotifications(notificationsPlugin) async {
  await notificationsPlugin.cancelAll();
  print('All notifications cancelled');
}

Future<void> scheduleNextNotifications(notificationsPlugin) async {
  await cancelAllNotifications(notificationsPlugin);
  List<bool> notifications = await loadNotifications();
  if (notifications[0])
    await scheduleNextLensNotification(notificationsPlugin);
  if (notifications[1])
    await scheduleNextToothBrushNotification(notificationsPlugin);
  if (notifications[2])
    await scheduleNextWaterNotification(notificationsPlugin);
}

Future<void> scheduleNextLensNotification(notificationsPlugin) async {
  final durations = await loadLensDurations();
  final bool newLenses = (durations['L']! < 2 || durations['R']! < 2);
  LensNotification notification = LensNotification(newLenses: newLenses);

  // final DateTime scheduledDate = inSeconds(5);  // only for debugging
  DateTime scheduledDate = instanceOfHour(8);
  scheduledDate = isInPast(scheduledDate) ? scheduledDate.add(const Duration(days: 1)) : scheduledDate;
  print('Next lens notification: $scheduledDate');

  await scheduleNextNotification(notificationsPlugin, notification, scheduledDate);
}

Future<void> scheduleNextToothBrushNotification(notificationsPlugin) async {
  ToothBrushNotification notification = ToothBrushNotification();

  final DateTime scheduledDate = nextInstanceOfSunday8PM();
  print('Next tooth brush notification: $scheduledDate');

  await scheduleNextNotification(notificationsPlugin, notification, scheduledDate);
}

Future<void> scheduleNextWaterNotification(notificationsPlugin) async {
  DateTime scheduledDate = nextWaterDate();

  WaterNotification notification = WaterNotification();
  print('Next water notification: $scheduledDate');
  await scheduleNextNotification(notificationsPlugin, notification, scheduledDate);
}

Future<void> scheduleNextNotification(notificationsPlugin, notification, scheduledDate) async {
  await notificationsPlugin.zonedSchedule(
    notification.id,
    notification.title,
    notification.body,
    scheduledDate,
    loadPlatformChannelSpecifics(notification.actions),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    payload: notification.payload,
  );
}

NotificationDetails loadPlatformChannelSpecifics(List<AndroidNotificationAction> actions) {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    '0',  // channel id
    'Notifications',  // channel name
    channelDescription: 'Notifications',  // channel description
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    ongoing: true,
    autoCancel: false,
    styleInformation: const BigTextStyleInformation(''),
    actions: actions,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  return platformChannelSpecifics;
}


class NotificationService {
  GlobalKey<NavigatorState> navigatorKey;
  NotificationService( {required this.navigatorKey} );

  FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  String initialRoute = '/';

  Future<void> initNotification() async {
    // Request permission for notifications
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    bool action = false;

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            break;
          case NotificationResponseType.selectedNotificationAction:
            action = true;
            if (notificationResponse.actionId == 'no_action') {
              addOneDay();
            }
            break;
        }
        await scheduleNextNotifications(notificationsPlugin);

        // App is open
        NavigatorState? key = navigatorKey.currentState;
        if (key != null) {
          if (action) {
            action = false;
            key.pushReplacementNamed('/');
          } else if (notificationResponse.id == 0) {  // renew lenses
            key.pushReplacementNamed('/');
          } else if (notificationResponse.id == 1) {  // lenses wearing
            key.pushNamed('/lens_notification');
          } else if (notificationResponse.id == 2) {  // tooth brush reminder
            key.pushNamed('/tooth_brush_notification');
          } else if (notificationResponse.id == 3) {  // water reminder
            key.pushNamed('/water_notification');
          }
        }
      }
    );

    // App is closed
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await notificationsPlugin.getNotificationAppLaunchDetails();
    bool didNotificationLaunchApp = notificationAppLaunchDetails ?.didNotificationLaunchApp ?? false;
    if (didNotificationLaunchApp) {
      String? actionId = notificationAppLaunchDetails!.notificationResponse!.actionId;
      if (actionId != null) {
        if (actionId == 'no_action') {
          addOneDay();
        }
        initialRoute = '/';
      } else {
        String? route = notificationAppLaunchDetails.notificationResponse!.payload;
        initialRoute = '/$route';
      }
      await scheduleNextNotifications(notificationsPlugin);
    }
  }
}
