import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'options.dart';

class ExistingNINScreen extends StatefulWidget {
  final String citizenId;

  const ExistingNINScreen({
    required this.citizenId,
  });

  @override
  _ExistingNINScreenState createState() => _ExistingNINScreenState();
}

class _ExistingNINScreenState extends State<ExistingNINScreen> {
  String? firstName;
  String? lastName;
  DateTime? lastVisit;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    _fetchCitizen();
  }

  Future<void> _fetchCitizen() async {
    final doc = await FirebaseFirestore.instance.collection('citizens').doc(widget.citizenId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        firstName = data['first_name'] ?? '';
        lastName = data['last_name'] ?? '';
        Timestamp? lastVisitTimestamp = data['last_visit'];
        lastVisit = lastVisitTimestamp != null ? lastVisitTimestamp.toDate() : null;
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return Scaffold(
        appBar: AppBar(title: Text('Visitor Found')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (firstName == null || lastName == null || lastVisit == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Visitor Found')),
        body: Center(child: Text('Citizen record not found.')),
      );
    }

    final formattedDate = DateFormat.yMMMMd().format(lastVisit!);
    final bool canEnter = DateTime.now().difference(lastVisit!).inDays >= 7;

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
                  final docRef = FirebaseFirestore.instance.collection('citizens').doc(widget.citizenId);
                  final docSnapshot = await docRef.get();
                  final data = docSnapshot.data() ?? {};
                  if (canEnter) {
                    final now = DateTime.now();
                    await docRef.update({
                      'last_visit': now,
                      'visit_history': FieldValue.arrayUnion([now]),
                      'nin': data['nin'] ?? '', // Keep existing nin if any
                      'vc_serial': data['vc_serial'] ?? '', // Keep existing vc if any
                    });

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => OptionsScreen()),
                      (route) => false,
                    );
                  } else {
                    if (data['nin'] == null || data['nin'] == '') {
                      await docRef.update({
                        'nin': data['nin'] ?? '',
                      });
                    }
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