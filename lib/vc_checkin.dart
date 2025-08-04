import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VCCheckInScreen extends StatefulWidget {
  @override
  _VCCheckinScreenState createState() => _VCCheckinScreenState();
}

class _VCCheckinScreenState extends State<VCCheckInScreen> {
  final TextEditingController _ninController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voters Card Check In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: TextField(
            controller: _ninController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Voters Card Number',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}