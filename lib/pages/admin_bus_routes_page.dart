import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminBusRoutesPage extends StatefulWidget {
  @override
  _AdminBusRoutesPageState createState() => _AdminBusRoutesPageState();
}

class _AdminBusRoutesPageState extends State<AdminBusRoutesPage> {
  Future<void> _deleteRoute(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('bus_routes').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Route deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error deleting route: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(String docId, String busName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete Route'),
        content: Text('Are you sure you want to delete "$busName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteRoute(docId);
    }
  }

  Future<void> _showEditDialog(String docId, Map<String, dynamic> data) async {
    final busNameController = TextEditingController(text: data['busName'] ?? '');
    final startPointController = TextEditingController(text: data['startPoint'] ?? '');
    final endPointController = TextEditingController(text: data['endPoint'] ?? '');
    final costController = TextEditingController(text: data['cost']?.toString() ?? '');
    final scheduleController = TextEditingController(text: data['schedule']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Edit Route'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: busNameController,
                  decoration: InputDecoration(labelText: 'Bus Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: startPointController,
                  decoration: InputDecoration(labelText: 'Start Point'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: endPointController,
                  decoration: InputDecoration(labelText: 'End Point'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: costController,
                  decoration: InputDecoration(labelText: 'Cost (TK)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Must be a number';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: scheduleController,
                  decoration: InputDecoration(
                    labelText: 'Schedule (optional)',
                    hintText: 'e.g., 08:00, 10:00, 12:00',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(c).pop(true);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await FirebaseFirestore.instance.collection('bus_routes').doc(docId).update({
          'busName': busNameController.text.trim(),
          'startPoint': startPointController.text.trim(),
          'endPoint': endPointController.text.trim(),
          'cost': double.parse(costController.text.trim()),
          'schedule': scheduleController.text.trim().isEmpty ? null : scheduleController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Route updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error updating route: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    busNameController.dispose();
    startPointController.dispose();
    endPointController.dispose();
    costController.dispose();
    scheduleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bus Routes'),
        backgroundColor: Colors.deepPurple,
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
                  Icon(Icons.directions_bus, size: 100, color: Colors.deepPurple),
                  SizedBox(height: 20),
                  Text(
                    'No bus routes found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Add routes from the Admin Dashboard.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = (doc.data() as Map<String, dynamic>?) ?? {};
              final busName = data['busName'] ?? data['routeNumber'] ?? 'Unknown';
              final start = data['startPoint'] ?? '-';
              final end = data['endPoint'] ?? '-';
              final cost = data['cost'] != null ? data['cost'].toString() : 'N/A';
              final schedule = data['schedule']?.toString();
              final createdBy = data['createdBy'] ?? 'admin';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  busName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(start, style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Icon(Icons.flag, size: 16, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text(end, style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text('Schedule: ${schedule ?? 'N/A'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                SizedBox(height: 4),
                                Text('Cost: ৳$cost', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                SizedBox(height: 4),
                                Text('By: $createdBy', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () => _showEditDialog(doc.id, data),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _showDeleteConfirmation(doc.id, busName),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
