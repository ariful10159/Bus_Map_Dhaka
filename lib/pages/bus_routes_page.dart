import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusRoutesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Routes List'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bus_routes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus, size: 100, color: Colors.teal),
                  SizedBox(height: 20),
                  Text(
                    'No bus routes found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Admins have not uploaded any routes yet.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = (doc.data() as Map<String, dynamic>?) ?? {};
              final busName =
                  data['busName'] ?? data['routeNumber'] ?? 'Unknown';
              final start = data['startPoint'] ?? '-';
              final end = data['endPoint'] ?? '-';
              final cost = data['cost'] != null
                  ? data['cost'].toString()
                  : 'N/A';
              final schedule = data['schedule']?.toString();
              final createdBy = data['createdBy'] ?? 'admin';
              String createdAtStr = '';
              final createdAt = data['createdAt'];
              try {
                if (createdAt is Timestamp)
                  createdAtStr = createdAt.toDate().toLocal().toString();
                else if (createdAt != null)
                  createdAtStr = createdAt.toString();
              } catch (_) {
                createdAtStr = '';
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: Icon(Icons.directions_bus, color: Colors.teal),
                  ),
                  title: Text(
                    busName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('$start → $end'),
                      SizedBox(height: 4),
                      Text(
                        'Schedule: ${schedule ?? 'N/A'}',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'By: $createdBy',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Spacer(),
                          if (createdAtStr.isNotEmpty)
                            Text(
                              createdAtStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '৳$cost',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () async {
                    // Show detail dialog with all available fields
                    final entries = <Widget>[];
                    final map = Map<String, dynamic>.from(data);
                    map['id'] = doc.id;
                    map.forEach((k, v) {
                      entries.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '$k:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(flex: 7, child: Text('${v ?? 'null'}')),
                            ],
                          ),
                        ),
                      );
                    });

                    await showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text('Route details'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: entries,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(c).pop(),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
