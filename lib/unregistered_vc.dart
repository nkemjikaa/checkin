import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vc_registration.dart';

class UnregisteredVCScreen extends StatelessWidget {
  final String serial;
  const UnregisteredVCScreen({required this.serial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unregistered Voters Card')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voters Card $serial is not registered.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VCRegistration(serial: serial),
                  ),
                );
              },
              child: Text('Register this Voters Card'),
            ),
          ],
        ),
      ),
    );
  }
}