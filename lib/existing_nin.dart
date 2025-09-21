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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('citizens').doc(widget.citizenId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Visitor Found')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('Visitor Found')),
            body: Center(child: Text('Citizen record not found.')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String firstName = data['first_name'] ?? '';
        final String lastName = data['last_name'] ?? '';
        List<DateTime> history = [];
        if (data['visit_history'] != null && data['visit_history'] is List) {
          print("Visit history raw: ${data['visit_history']}");
          for (var ts in data['visit_history']) {
            if (ts is Timestamp) {
              history.add(ts.toDate());
            } else if (ts is DateTime) {
              history.add(ts);
            }
          }
          print("Parsed dates: $history");
        }
        history.sort((a, b) => b.compareTo(a)); // descending order
        final DateTime? lastVisit = history.isNotEmpty ? history.first : null;

        if (lastVisit == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Visitor Found')),
            body: Center(child: Text('Citizen record not found.')),
          );
        }

        final formattedDate = DateFormat.yMMMMd().format(lastVisit);
        final bool canEnter = DateTime.now().difference(lastVisit).inDays >= 7;

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
                      if (!canEnter) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Entry denied: must wait at least 7 days since last visit.')),
                        );
                      } else {
                        final docRef = FirebaseFirestore.instance.collection('citizens').doc(widget.citizenId);
                        final docSnapshot = await docRef.get();
                        final data = docSnapshot.data() ?? {};
                        final now = DateTime.now();
                        await docRef.update({
                          'last_visit': now,
                          'visit_history': FieldValue.arrayUnion([now]),
                          'nin': data['nin'] ?? '',
                          'vc_serial': data['vc_serial'] ?? '',
                        });
                      }

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => OptionsScreen()),
                        (route) => false,
                      );
                    },
                    child: Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}