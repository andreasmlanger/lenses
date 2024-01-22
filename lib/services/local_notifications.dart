import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'local_time_zone.dart';
import 'package:lenses/services/local_storage.dart';
import 'package:lenses/services/notifications.dart';


Future<bool> isNotificationScheduled(flutterLocalNotificationsPlugin) async {
  final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  return pendingNotifications.length > 0;
}

Future<void> updateAllNotifications(flutterLocalNotificationsPlugin) async {
  await cancelAllNotifications(flutterLocalNotificationsPlugin);
  await scheduleNextNotifications(flutterLocalNotificationsPlugin);
}

Future<void> cancelAllNotifications(flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancelAll();
  print('All notifications cancelled');
}

Future<void> scheduleNextNotifications(flutterLocalNotificationsPlugin) async {
  await scheduleNextLensNotification(flutterLocalNotificationsPlugin);
  await scheduleNextToothBrushNotification(flutterLocalNotificationsPlugin);
}

Future<void> scheduleNextLensNotification(flutterLocalNotificationsPlugin) async {
  final durations = await loadLensDurations();
  final bool newLenses = (durations['L']! < 2 || durations['R']! < 2);
  LensNotification notification = LensNotification(newLenses: newLenses);

  // final scheduledDate = inSeconds(5);  // only for debugging
  final scheduledDate = nextInstanceOf8AM();
  print('Next lens notification: $scheduledDate');

  await scheduleNextNotification(flutterLocalNotificationsPlugin, notification, scheduledDate);
}

Future<void> scheduleNextToothBrushNotification(flutterLocalNotificationsPlugin) async {
  ToothBrushNotification notification = ToothBrushNotification();

  // final scheduledDate = inSeconds(5);  // only for debugging
  final scheduledDate = nextInstanceOfSunday8PM();
  print('Next tooth brush notification: $scheduledDate');

  await scheduleNextNotification(flutterLocalNotificationsPlugin, notification, scheduledDate);
}

Future<void> scheduleNextNotification(flutterLocalNotificationsPlugin, notification, scheduledDate) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
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
        await cancelAllNotifications(notificationsPlugin);

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
          }
        }
      }
    );

    // App is closed
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await notificationsPlugin.getNotificationAppLaunchDetails();
    bool didNotificationLaunchApp = notificationAppLaunchDetails ?.didNotificationLaunchApp ?? false;
    if (didNotificationLaunchApp) {
      await cancelAllNotifications(notificationsPlugin);
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
