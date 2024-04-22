import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LensNotification {
  final bool newLenses;
  late final int id;
  late final String title;
  late final String body;
  late final String payload;
  late final List<AndroidNotificationAction> actions;

  LensNotification({
    required this.newLenses,
  }) {

    if (newLenses) {
      id = 0;
      title = 'Time to change lenses!';
      body = '';
      payload = '';
      actions = <AndroidNotificationAction>[];
    } else {
      id = 1;
      title = 'Are you wearing lenses today?';
      body = '';
      payload = 'lens_notification';
      actions = <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'yes_action', // ID of the action
          'Yes', // Label of the action
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'no_action', // ID of the action
          'No', // Label of the action
          showsUserInterface: true,
        )
      ];
    }
  }
}

class ToothBrushNotification {
  late final int id = 2;
  late final String title = 'Elmex Gelee';
  late final String body = 'Brush teeth with Elmex Gelee today!';
  late final String payload = 'tooth_brush_notification';
  late final List<AndroidNotificationAction> actions = <AndroidNotificationAction>[];
}

class WaterNotification {
  late final int id = 3;
  late final String title = 'Drink Water';
  late final String body = 'Drink water now!';
  late final String payload = 'water_notification';
  late final List<AndroidNotificationAction> actions = <AndroidNotificationAction>[];
}
