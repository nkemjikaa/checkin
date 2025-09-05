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
                  final vc_serial = _vcController.text.trim().toUpperCase();
                  if (!isValidVC(vc_serial)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Incorrect Voter Card Serial.')),
                    );
                  } else {
                    final vcSerialdoc = await FirebaseFirestore.instance.collection('vc_serial').doc(vc_serial).get();
                    if (!vcSerialdoc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnregisteredVCScreen(serial: vc_serial),
                        ),
                      );
                    } else {
                      final data = vcSerialdoc.data()!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExistingVCScreen(
                            citizenId: data['citizenId'],
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