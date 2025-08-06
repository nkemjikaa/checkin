import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'unregistered_vc.dart';
import 'existing_vc.dart';

class VCCheckInScreen extends StatefulWidget {
  @override
  _VCCheckInScreenState createState() => _VCCheckInScreenState();
}

class _VCCheckInScreenState extends State<VCCheckInScreen> {
  final TextEditingController _vcController = TextEditingController();

  bool isValidVC(String input) {
    final valid = RegExp(r'^[A-Za-z]\d{8}$');
    return valid.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VC Check In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vcController,
                decoration: InputDecoration(
                  labelText: 'Enter Voter Card Serial',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final serial = _vcController.text.trim().toUpperCase();
                  if (!isValidVC(serial)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Incorrect Voter Card Serial.')),
                    );
                  } else {
                    final doc = await FirebaseFirestore.instance.collection('voters').doc(serial).get();
                    if (!doc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnregisteredVCScreen(serial: serial),
                        ),
                      );
                    } else {
                      final data = doc.data()!;
                      final firstName = data['first_name'] ?? 'Unknown';
                      final lastName = data['last_name'] ?? 'Unknown';
                      final lastVisit = (data['last_visit'] as Timestamp).toDate();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExistingVCScreen(
                            firstName: firstName,
                            lastName: lastName,
                            lastVisit: lastVisit,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}