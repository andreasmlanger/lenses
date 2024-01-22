import 'package:flutter/material.dart';
import 'package:lenses/services/constants.dart';


class ToothBrushNotificationScreen extends StatelessWidget {
  const ToothBrushNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Image(
                  image: AssetImage('assets/tooth-brush.png'),
                  width: 200.0,
                  height: 200.0,
                ),
              ),
            ),
            const Text(
                'Brush teeth with Elmex Gelee today!',
                style: TextStyle(
                  fontSize: 20,
                )
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor1, // Change the button color here
                    minimumSize: const Size(120, 80), // Set the button size
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 20, // Change the text size
                      color: Colors.white, // Change the text color
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
