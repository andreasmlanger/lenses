import 'package:flutter/material.dart';
import 'package:lenses/services/constants.dart';
import 'package:lenses/services/local_storage.dart';


class LensNotificationScreen extends StatelessWidget {
  const LensNotificationScreen({Key? key}) : super(key: key);

  Widget yesNoButton(context, String label) {
    return ElevatedButton(
      onPressed: () {
        if (label == 'No') {
          addOneDay();
        }
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: label == 'Yes' ? accentColor1 : accentColor2,
        minimumSize: const Size(120, 80),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Are you wearing lenses today?',
              style: TextStyle(
                fontSize: 20,
              )
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                yesNoButton(context, 'Yes'),
                yesNoButton(context, 'No'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
