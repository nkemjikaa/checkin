import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'vc_completion.dart';

class VCRegistration extends StatefulWidget {
  final String serial;
  const VCRegistration({required this.serial});

  @override
  _VCRegistrationState createState() => _VCRegistrationState();
}

class _VCRegistrationState extends State<VCRegistration> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _dob;
  bool _isSubmitting = false;
  String? _error;

  Future<void> _registerUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || _dob == null) {
      setState(() => _error = 'All fields are required.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final citizensCollection = FirebaseFirestore.instance.collection('citizens');
      final querySnapshot = await citizensCollection
          .where('first_name', isEqualTo: firstName)
          .where('last_name', isEqualTo: lastName)
          .where('dob', isEqualTo: _dob!.toIso8601String())
          .get();

      DocumentReference citizenDocRef;
      Map<String, dynamic> citizenData;

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing citizen
        citizenDocRef = querySnapshot.docs.first.reference;
        await citizenDocRef.update({'vc_serial': widget.serial});
        final updatedDoc = await citizenDocRef.get();
        citizenData = updatedDoc.data() as Map<String, dynamic>;
      } else {
        // Create new citizen
        citizenData = {
          'first_name': firstName,
          'last_name': lastName,
          'dob': _dob!.toIso8601String(),
          'nin': null,
          'vc_serial': widget.serial,
          'last_visit': DateTime.now(),
          'visit_history': [DateTime.now()],
        };
        citizenDocRef = await citizensCollection.add(citizenData);
      }

      // Create voter document with reference to citizen
      await FirebaseFirestore.instance.collection('vc_serial').doc(widget.serial).set({
        'citizenId': citizenDocRef.id,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VCCompletionScreen(
            firstName: citizenData['first_name'],
            lastName: citizenData['last_name'],
            lastVisit: citizenData['last_visit'] is Timestamp
                ? (citizenData['last_visit'] as Timestamp).toDate()
                : citizenData['last_visit'] is DateTime
                    ? citizenData['last_visit']
                    : DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = 'Registration failed: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Voters Card')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Register Voters Card: ${widget.serial}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(_dob == null
                        ? 'Date of Birth not selected'
                        : 'DOB: ${DateFormat.yMMMd().format(_dob!)}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Select DOB'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _registerUser,
                child: _isSubmitting ? CircularProgressIndicator() : Text('Register & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}