import 'package:flutter/material.dart';
import 'package:lenses/services/constants.dart';


String getMessage(String notificationType) {
  if (notificationType == 'tooth-brush') {
    return 'Brush teeth with Elmex Gelee today!';
  } else if (notificationType == 'water') {
    return 'Drink water now!';
  } else {
    return '';
  }
}

class CustomNotificationScreen extends StatelessWidget {
  final String notificationType;
  const CustomNotificationScreen(this.notificationType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Image(
                  image: AssetImage('assets/${notificationType}.png'),
                  width: 200.0,
                  height: 200.0,
                ),
              ),
            ),
            Text(
                getMessage(notificationType),
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
