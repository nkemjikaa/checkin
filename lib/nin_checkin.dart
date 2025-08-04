import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'unregistered_nin.dart';
import 'existing_nin.dart';

class NINCheckInScreen extends StatefulWidget {
  @override
  _NINCheckinScreenState createState() => _NINCheckinScreenState();
}

class _NINCheckinScreenState extends State<NINCheckInScreen> {
  final TextEditingController _ninController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NIN Check In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ninController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter NIN',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final nin = _ninController.text.trim();
                  if (nin.length != 11) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Incorrect NIN.')),
                    );
                  } else {
                    final doc = await FirebaseFirestore.instance.collection('users').doc(nin).get();
                    if (!doc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnregisteredNINScreen(nin: nin),
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
                          builder: (context) => ExistingNINScreen(
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