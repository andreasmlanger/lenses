import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


DateTime getNow() {
  return tz.TZDateTime.now(tz.local);
}

DateTime getToday() {
  final DateTime now = getNow();
  final String strippedDateString = stripDateString(now);
  final DateTime today = DateTime.parse(strippedDateString);
  return today;
}

String stripDateString(DateTime date) {
  return date.toString().split(' ')[0];
}

int calculateDaysBetween(date1, date2) {
  return date2.isBefore(date1) ? 0 : date2.difference(date1).inDays;
}

DateTime inDays(int days) {
  final DateTime now = getNow();
  final DateTime date = now.add(Duration(days: days));
  final String dateString = stripDateString(date);
  return DateTime.parse(dateString);
}

Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

tz.TZDateTime instanceOfHour(hour) {
  final now = getNow();
  final instance = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    0,
  );
  return instance;
}

bool isInPast(instance) {
  final now = getNow();
  return instance.isBefore(now);
}

bool isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

tz.TZDateTime nextInstanceOfSunday8PM() {
  final now = getNow();
  final daysUntilSunday = 7 - now.weekday;
  final nextSunday = now.add(Duration(days: daysUntilSunday));
  final nextSunday8PM = tz.TZDateTime(
    tz.local,
    nextSunday.year,
    nextSunday.month,
    nextSunday.day,
    20,  // 8 PM
    0,
  );
  return nextSunday8PM.isBefore(now) ? nextSunday8PM.add(const Duration(days: 7)) : nextSunday8PM;
}

// Only for debugging
tz.TZDateTime inSeconds(int seconds) {
  final now = tz.TZDateTime.now(tz.local);
  return now.add(Duration(seconds: seconds));
}

DateTime nextWaterDate() {
  final List<int> hours = [10, 14, 18];
  for (int hour in hours) {
    DateTime scheduledDate = instanceOfHour(hour);
    if (!isInPast(scheduledDate) && scheduledDate.weekday < 6) {
      return scheduledDate;
    }
  }
  DateTime scheduledDate = instanceOfHour(hours[0]);
  scheduledDate = scheduledDate.add(const Duration(days: 1));
  while (scheduledDate.weekday > 5) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));  // if weekend, add one day
  }
  print(scheduledDate.weekday);
  return scheduledDate;
}
