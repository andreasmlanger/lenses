import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenses/services/local_time_zone.dart';


Future<void> saveLensReplacementDate(String type, DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  final String dateString = stripDateString(date); // save only YYYY-MM-DD
  await prefs.setString(type, dateString);
  print('$type: $dateString');
}

Future<Map<String, int>> loadLensDurations() async {
  final DateTime now = getToday();

  final prefs = await SharedPreferences.getInstance();
  final String? dateStringL = prefs.getString('L');
  final String? dateStringR = prefs.getString('R');

  final durationL = dateStringL != null ? calculateDaysBetween(now, DateTime.parse(dateStringL)) : 28;
  final durationR = dateStringR != null ? calculateDaysBetween(now, DateTime.parse(dateStringR)) : 28;

  return {'L': durationL, 'R': durationR};
}

void addOneDay() async {
  var lensDurations = await loadLensDurations();
  await saveLensReplacementDate('L', inDays(lensDurations['L']! + 1));
  await saveLensReplacementDate('R', inDays(lensDurations['R']! + 1));
}

Future<void> saveNotifications(notifications) async {
  final prefs = await SharedPreferences.getInstance();
  for (int i = 0; i < notifications.length; i++)
    await prefs.setBool(i.toString(), notifications[i]);
}

Future<List<bool>> loadNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  List<bool?> notifications = [prefs.getBool('0'), prefs.getBool('1'), prefs.getBool('2')];
  return notifications.map((value) => value ?? false).toList();
}
