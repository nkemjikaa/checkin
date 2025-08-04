import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nin_registration.dart';

class UnregisteredNINScreen extends StatelessWidget {
  final String nin;
  const UnregisteredNINScreen({required this.nin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unregistered NIN')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NIN $nin is not registered.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NINRegistration(nin: nin),
                  ),
                );
              },
              child: Text('Register this NIN'),
            ),
          ],
        ),
      ),
    );
  }
}