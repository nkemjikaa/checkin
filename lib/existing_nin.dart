import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'options.dart';

class ExistingNINScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final DateTime lastVisit;

  const ExistingNINScreen({
    required this.firstName,
    required this.lastName,
    required this.lastVisit,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(lastVisit);
    final bool canEnter = DateTime.now().difference(lastVisit).inDays >= 7;

    return Scaffold(
      appBar: AppBar(title: Text('Visitor Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canEnter ? Icons.check_circle : Icons.cancel,
                color: canEnter ? Colors.green : Colors.red,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                '$firstName $lastName',
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
                onPressed: () async {
                  if (canEnter) {
                    final now = DateTime.now();
                    await FirebaseFirestore.instance.collection('users').doc('$firstName$lastName').update({
                      'last_visit': now,
                      'visit_history': FieldValue.arrayUnion([now]),
                    });

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => OptionsScreen()),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Entry denied: must wait at least 7 days since last visit.')),
                    );
                  }
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