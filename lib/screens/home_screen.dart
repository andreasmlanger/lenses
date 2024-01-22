import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:lenses/services/constants.dart';
import 'package:lenses/services/local_notifications.dart';
import 'package:lenses/services/local_storage.dart';
import 'package:lenses/services/local_time_zone.dart';


class Home extends StatefulWidget {
  static const routeName = '/';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const Home(
      this.flutterLocalNotificationsPlugin, {
        Key? key,
      }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<Home> {
  Map<String, int> durations = {'L': 28, 'R': 28};  // initialize
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _updateDurations();
  }

  Future<void> _updateDurations() async {
    final lensDurations = await loadLensDurations();
    setState(() {
      durations = lensDurations;
    });
  }

  void openDurationsSelectorDialog(BuildContext context, String type) {
    int selectedValue = durations[type]! < 28 ? durations[type]! : 28;
    final notificationsPlugin = widget.flutterLocalNotificationsPlugin;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Select Duration',
            style: TextStyle(
              fontFamily: 'Nunito',
            )
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return NumberPicker(
                value: selectedValue,
                minValue: 1,
                maxValue: 28,
                onChanged: (value) {
                  setState(() => durations[type] = value);
                  selectedValue = value;
                },
              );
            }
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  durations[type] = selectedValue;
                });
                await saveLensReplacementDate(type, inDays(selectedValue));
                await updateAllNotifications(notificationsPlugin);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future _displayBottomSheet(BuildContext context) async {
    final notificationsPlugin = widget.flutterLocalNotificationsPlugin;
    final isNotificationEnabled = await isNotificationScheduled(notificationsPlugin);
    setState(() {
      notificationsEnabled = isNotificationEnabled;
    });
    return showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: notificationsEnabled,
                  onChanged: (newValue) {
                    setState(() {
                      notificationsEnabled = newValue;
                    });
                    newValue ? scheduleNextNotifications(notificationsPlugin) : cancelAllNotifications(notificationsPlugin);
                  },
                  activeColor: primaryColor,
                ),
                SizedBox(width: 20.0),
                Text(
                  'Notifications',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget lensDurationBox(String type) {
    return GestureDetector(
      onTap: () {
        openDurationsSelectorDialog(context, type);
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: type == 'L' ? accentColor1 : accentColor2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            durations[type].toString(),
            style: const TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget renewButton(String type) {
    final notificationsPlugin = widget.flutterLocalNotificationsPlugin;
    if (durations[type]! < 1) {
      return ElevatedButton.icon(
        onPressed: () async {
          setState(() {
            durations[type] = 28;
          });
          await saveLensReplacementDate(type, inDays(28));
          await updateAllNotifications(notificationsPlugin);
        },
        icon: const Icon(
          Icons.refresh,
          size: 24.0,
        ),
        label: const Text(''),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.green[500],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 12.0, 18.0, 12.0),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lens Durations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          )
        ),
        backgroundColor: primaryColor,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              _displayBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'assets/contact-lens.png',
                height: 80.0,
              ),
              Image.asset(
                'assets/app_icon.png',
                height: 120.0,
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                child: Image.asset(
                  'assets/contact-lens.png',
                  height: 80.0,
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 320,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      lensDurationBox('L'),
                      const SizedBox(height: 25.0),
                      renewButton('L'),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      lensDurationBox('R'),
                      const SizedBox(height: 25.0),
                      renewButton('R'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}