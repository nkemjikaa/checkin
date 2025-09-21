import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('citizens').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }
          final docs = snapshot.data!.docs;
          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          int totalVisits = 0;
          int visitsLast7Days = 0;
          List<Map<String, dynamic>> citizens = [];
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            // Assume visit_history is a list of timestamps
            final visits = (data['visit_history'] as List<dynamic>? ?? []);
            totalVisits += visits.length;
            visitsLast7Days += visits.where((v) {
              if (v is Timestamp) {
                return v.toDate().isAfter(sevenDaysAgo);
              } else if (v is DateTime) {
                return v.isAfter(sevenDaysAgo);
              }
              return false;
            }).length;
            // Find most recent visit
            DateTime? lastVisit;
            if (data['last_visit'] is Timestamp) {
              lastVisit = (data['last_visit'] as Timestamp).toDate();
            } else if (data['last_visit'] is DateTime) {
              lastVisit = data['last_visit'] as DateTime;
            } else if (visits.isNotEmpty) {
              final sorted = visits.map((v) {
                if (v is Timestamp) return v.toDate();
                if (v is DateTime) return v;
                return null;
              }).whereType<DateTime>().toList();
              if (sorted.isNotEmpty) {
                sorted.sort((a, b) => b.compareTo(a));
                lastVisit = sorted.first;
              }
            }
            citizens.add({
              'first_name': data['first_name'] ?? '',
              'last_name': data['last_name'] ?? '',
              'nin': data['nin'] ?? '',
              'vc_serial': data['vc_serial'] ?? '',
              'dob': data['dob'],
              'last_visit': lastVisit,
              'visit_history': visits,
            });
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(label: 'Total Citizens', value: docs.length.toString()),
                    _StatCard(label: 'Total Visits', value: totalVisits.toString()),
                    _StatCard(label: 'Visits (7d)', value: visitsLast7Days.toString()),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Citizens', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                      columns: const [
                        DataColumn(label: Text('First Name')),
                        DataColumn(label: Text('Last Name')),
                        DataColumn(label: Text('NIN')),
                        DataColumn(label: Text('VC')),
                        DataColumn(label: Text('DOB')),
                        DataColumn(label: Text('Last Visit')),
                        DataColumn(label: Text('Visits')),
                      ],
                      rows: citizens.map((citizen) {
                        String formatDate(dynamic date) {
                          DateTime? dt;
                          if (date is Timestamp) {
                            dt = date.toDate();
                          } else if (date is DateTime) {
                            dt = date;
                          } else {
                            return 'Unknown';
                          }
                          return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                        }

                        final dobStr = citizen['dob'] != null ? formatDate(citizen['dob']) : 'Unknown';
                        final lastVisit = citizen['last_visit'] as DateTime?;
                        final lastVisitStr = lastVisit != null
                            ? '${lastVisit.year}-${lastVisit.month.toString().padLeft(2, '0')}-${lastVisit.day.toString().padLeft(2, '0')}'
                            : 'Never';
                        final visitsCount = (citizen['visit_history'] as List<dynamic>).length.toString();

                        return DataRow(
                          cells: [
                            DataCell(Text(citizen['first_name'] ?? '')),
                            DataCell(Text(citizen['last_name'] ?? '')),
                            DataCell(Text(citizen['nin'] ?? '')),
                            DataCell(Text(citizen['vc_serial'] ?? '')),
                            DataCell(Text(dobStr)),
                            DataCell(Text(lastVisitStr)),
                            DataCell(Text(visitsCount)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}