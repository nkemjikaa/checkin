import 'package:flutter/material.dart';
import 'options.dart';
import 'package:intl/intl.dart';

class NINCompletionScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final DateTime lastVisit;

  const NINCompletionScreen({
    required this.firstName,
    required this.lastName,
    required this.lastVisit,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(lastVisit);

    return Scaffold(
      appBar: AppBar(title: Text('Registration Complete')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text(
                'Welcome, $firstName $lastName!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Last Visit: $formattedDate',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => OptionsScreen()),
                    (route) => false,
                  );
                },
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}