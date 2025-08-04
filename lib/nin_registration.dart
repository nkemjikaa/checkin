import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'nin_completion.dart';

class NINRegistration extends StatefulWidget {
  final String nin;
  const NINRegistration({required this.nin});

  @override
  _NINRegistrationState createState() => _NINRegistrationState();
}

class _NINRegistrationState extends State<NINRegistration> {
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
      await FirebaseFirestore.instance.collection('users').doc(widget.nin).set({
        'first_name': firstName,
        'last_name': lastName,
        'dob': _dob!.toIso8601String(),
        'last_visit': DateTime.now(),
        'visit_history': FieldValue.arrayUnion([DateTime.now()]),
      });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NINCompletionScreen(
            firstName: firstName,
            lastName: lastName,
            lastVisit: DateTime.now(),
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
      appBar: AppBar(title: Text('Register NIN')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Register NIN: ${widget.nin}', style: TextStyle(fontWeight: FontWeight.bold)),
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