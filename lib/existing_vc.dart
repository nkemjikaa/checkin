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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('citizens').doc(widget.citizenId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Visitor Found')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';

        List<dynamic> visitHistoryRaw = data['visit_history'] ?? [];
        List<DateTime> visitHistory = visitHistoryRaw.map<DateTime>((item) {
          if (item is Timestamp) {
            return item.toDate();
          } else if (item is DateTime) {
            return item;
          } else {
            return DateTime.fromMillisecondsSinceEpoch(0);
          }
        }).toList();

        visitHistory.sort((a, b) => b.compareTo(a)); // descending

        final lastVisit = visitHistory.isNotEmpty ? visitHistory.first : DateTime.now();

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
                      if (canEnter) {
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Entry denied: must wait at least 7 days since last visit.')),
                        );
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