import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';
import 'screens/lens_notification_screen.dart';
import 'screens/tooth_brush_notification_screen.dart';
import 'services/local_notifications.dart';
import 'services/local_time_zone.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureLocalTimeZone();
  NotificationService notificationService = NotificationService(navigatorKey: navigatorKey);
  await notificationService.initNotification();

  runApp(MyApp(
    initialRoute: notificationService.initialRoute,
    flutterLocalNotificationsPlugin: notificationService.notificationsPlugin,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyApp({
    Key? key,
    required this.initialRoute,
    required this.flutterLocalNotificationsPlugin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'Nunito',
      ),
      routes: {
        '/': (context) => Home(flutterLocalNotificationsPlugin),
        '/lens_notification': (context) => const LensNotificationScreen(),
        '/tooth_brush_notification': (context) => const ToothBrushNotificationScreen(),
      },
    );
  }
}
