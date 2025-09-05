import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'options.dart';

class ExistingVCScreen extends StatefulWidget {
  final String citizenId;

  const ExistingVCScreen({
    required this.citizenId,
  });

  @override
  _ExistingVCScreenState createState() => _ExistingVCScreenState();
}

class _ExistingVCScreenState extends State<ExistingVCScreen> {
  String? firstName;
  String? lastName;
  DateTime? lastVisit;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCitizenData();
  }

  Future<void> _fetchCitizenData() async {
    final doc = await FirebaseFirestore.instance.collection('citizens').doc(widget.citizenId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        firstName = data['first_name'] ?? '';
        lastName = data['last_name'] ?? '';
        Timestamp? lastVisitTimestamp = data['last_visit'];
        lastVisit = lastVisitTimestamp != null ? lastVisitTimestamp.toDate() : DateTime.now();
        isLoading = false;
      });
    } else {
      setState(() {
        firstName = '';
        lastName = '';
        lastVisit = DateTime.now();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Visitor Found')),
        body: Center(child: CircularProgressIndicator()),
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
                  final vcSerialExists = data.containsKey('vc_serial');

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
                    if (data['vc_serial'] == null || data['vc_serial'] == '') {
                      await docRef.update({
                        'vc_serial': data['vc_serial'] ?? '',
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