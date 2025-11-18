import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your admin pages here
import '../admin_login_page.dart';
import '../admin_registration_page.dart';
// Add other admin page imports as needed

class AdminRouteManager {
  static const String adminLogin = '/admin-login';
  static const String adminRegister = '/admin-register';
  static const String adminRoutes = '/admin-routes';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      adminLogin: (context) => AdminLoginPage(),
      adminRegister: (context) => const AdminRegistrationPage(),
      adminRoutes: (context) => const AdminRoutesList(),
      // Add other admin routes here
    };
  }
}

class AdminRoutesList extends StatelessWidget {
  const AdminRoutesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bus Routes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bus_routes')
            .orderBy('busName')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No routes found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final busName = data['busName'] ?? 'Unknown';
              final startPoint = data['startPoint'] ?? '';
              final endPoint = data['endPoint'] ?? '';
              final cost = data['cost']?.toString() ?? '';
              final schedule = data['schedule'] ?? '';
              final createdBy = data['createdBy'] ?? '';
              final updatedBy = data['updatedBy'] ?? '';
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        busName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('From: $startPoint'),
                      Text('To: $endPoint'),
                      Text('Cost: ৳$cost'),
                      if (schedule != null && schedule.toString().isNotEmpty)
                        Text('Schedule: $schedule'),
                      const SizedBox(height: 6),
                      Text(
                        'Created by: $createdBy',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (updatedBy != null && updatedBy.toString().isNotEmpty)
                        Text(
                          'Updated by: $updatedBy',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
