import 'package:flutter/material.dart';
import 'nin_checkin.dart';
import 'vc_checkin.dart';

class OptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Verification Method')),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NINCheckInScreen()),
              ),
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'Use NIN',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VCCheckInScreen()), // Replace with VoterCardScreen()
              ),
              child: Container(
                color: Colors.green,
                child: Center(
                  child: Text(
                    'Use Voter\'s Card',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}